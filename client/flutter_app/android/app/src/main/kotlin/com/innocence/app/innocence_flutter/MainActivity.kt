package com.innocence.app.innocence_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "innocence/assistant_vault")
            .setMethodCallHandler { call, result ->
                if (call.method !in listOf("encrypt", "decrypt")) { result.notImplemented(); return@setMethodCallHandler }
                try {
                    val input = call.arguments as? ByteArray ?: throw IllegalArgumentException()
                    require(input.isNotEmpty() && input.size <= 65536)
                    val alias = "innocence.assistant.byok.v1"
                    val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
                    if (!store.containsAlias(alias)) {
                        require(call.method == "encrypt")
                        KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore").apply {
                            init(KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).build())
                            generateKey()
                        }
                    }
                    val key = store.getKey(alias, null) as SecretKey
                    val cipher = Cipher.getInstance("AES/GCM/NoPadding")
                    val output = if (call.method == "encrypt") {
                        cipher.init(Cipher.ENCRYPT_MODE, key)
                        cipher.iv + cipher.doFinal(input)
                    } else {
                        require(input.size > 28)
                        cipher.init(Cipher.DECRYPT_MODE, key, GCMParameterSpec(128, input.copyOfRange(0, 12)))
                        cipher.doFinal(input.copyOfRange(12, input.size))
                    }
                    result.success(output)
                } catch (_: Exception) { result.error("vault_failed", "Credential protection failed.", null) }
            }
    }
}
