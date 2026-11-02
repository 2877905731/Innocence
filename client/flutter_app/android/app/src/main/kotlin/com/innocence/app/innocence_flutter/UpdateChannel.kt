package com.innocence.app.innocence_flutter

import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

internal class UpdateChannel(private val activity: FlutterActivity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "innocence/updates")
    @Suppress("DEPRECATION")
    private fun signatures(info: PackageInfo): Set<String> {
        val values = if (Build.VERSION.SDK_INT >= 28) info.signingInfo?.apkContentsSigners else info.signatures
        return values?.map { MessageDigest.getInstance("SHA-256").digest(it.toByteArray()).joinToString("") { b -> "%02x".format(b) } }?.toSet() ?: emptySet()
    }
    @Suppress("DEPRECATION")
    private fun flags() = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
    @Suppress("DEPRECATION")
    private fun code(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
    init {
        channel.setMethodCallHandler { call, result ->
            try {
                val own = activity.packageManager.getPackageInfo(activity.packageName, flags())
                when (call.method) {
                    "info" -> result.success(mapOf("platform" to "android", "arch" to "universal", "version" to own.versionName, "build" to code(own)))
                    "install" -> {
                        val path = call.argument<String>("path") ?: throw IllegalArgumentException()
                        val build = call.argument<Number>("build")?.toLong() ?: throw IllegalArgumentException()
                        val version = call.argument<String>("version") ?: throw IllegalArgumentException()
                        val file = File(path).canonicalFile
                        val directory = File(activity.cacheDir, "innocence-updates").canonicalFile
                        require(file.parentFile == directory && file.name.matches(Regex("[a-f0-9-]{36}\\.apk")) && file.isFile)
                        val archive = activity.packageManager.getPackageArchiveInfo(file.path, flags()) ?: throw IllegalArgumentException()
                        require(archive.packageName == activity.packageName && code(archive) == build && build > code(own) && archive.versionName == version)
                        val original = signatures(own)
                        require(original.isNotEmpty() && original == signatures(archive))
                        if (Build.VERSION.SDK_INT >= 26 && !activity.packageManager.canRequestPackageInstalls()) {
                            activity.startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:${activity.packageName}")))
                            result.success("permissionRequired")
                        } else {
                            val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", file)
                            activity.startActivity(Intent(Intent.ACTION_VIEW).setDataAndType(uri, "application/vnd.android.package-archive")
                                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
                            result.success("installerOpened")
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (_: Exception) { result.error("update_failed", "Update package or installation is unavailable.", null) }
        }
    }
}
