package com.innocence.app.innocence_flutter

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class FocusNoticeChannel(private val activity: MainActivity, messenger: BinaryMessenger) {
    private var permissionResult: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "innocence/focus_notice").setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "requestPermission" -> {
                        if (Build.VERSION.SDK_INT >= 33 &&
                            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                            if (permissionResult != null) {
                                result.error("busy", "Notification permission request is pending.", null)
                            } else {
                                permissionResult = result
                                activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 7301)
                            }
                        } else result.success(null)
                    }
                    "openSettings" -> {
                        val intent = if (!FocusNotices.allowed(activity)) {
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                        } else if (Build.VERSION.SDK_INT >= 31) {
                            Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:${activity.packageName}"))
                        } else Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${activity.packageName}"))
                        activity.startActivity(intent)
                        result.success(null)
                    }
                    "sync" -> {
                        val args = FocusNoticeArguments.parse(call.arguments)
                        result.success(FocusNotices.sync(activity, args.owner, args.key, args.active, args.paused,
                            args.deadline, args.remaining, args.completed, args.chinese))
                    }
                    else -> result.notImplemented()
                }
            } catch (_: IllegalArgumentException) {
                result.error("invalid_arguments", "Invalid timer snapshot.", null)
            } catch (_: Exception) {
                result.error("focus_notice_failed", "Unable to update timer notifications.", null)
            }
        }
    }

    fun onPermissionResult(requestCode: Int) {
        if (requestCode != 7301) return
        permissionResult?.success(null)
        permissionResult = null
    }
}

internal data class FocusNoticeArguments(val owner: String, val key: String, val active: Boolean,
    val paused: Boolean, val deadline: Long, val remaining: Int, val completed: Boolean, val chinese: Boolean) {
    companion object {
        fun parse(value: Any?): FocusNoticeArguments {
            val args = value as? Map<*, *> ?: throw IllegalArgumentException()
            val key = args["key"] as? String ?: throw IllegalArgumentException()
            val owner = args["owner"] as? String ?: throw IllegalArgumentException()
            val active = args["active"] as? Boolean ?: throw IllegalArgumentException()
            val paused = args["paused"] as? Boolean ?: throw IllegalArgumentException()
            val deadlineNumber = args["deadlineMs"] as? Number ?: throw IllegalArgumentException()
            val remainingNumber = args["remainingSeconds"] as? Number ?: throw IllegalArgumentException()
            require(deadlineNumber.toDouble().isFinite() && remainingNumber.toDouble().isFinite())
            val deadline = deadlineNumber.toLong()
            val remaining = remainingNumber.toLong()
            val completed = args["completed"] as? Boolean ?: throw IllegalArgumentException()
            val chinese = args["isChinese"] as? Boolean ?: throw IllegalArgumentException()
            require(owner.length <= 128 && key.length <= 256 && deadline >= 0 && remaining in 0..Int.MAX_VALUE.toLong())
            require(key.isEmpty() || (owner.isNotEmpty() && key.startsWith("$owner/")))
            require(!active || key.isNotEmpty())
            return FocusNoticeArguments(owner, key, active, paused, deadline, remaining.toInt(), completed, chinese)
        }
    }
}

internal object FocusNotices {
    private const val RUNNING_ID = 7302
    private const val FINISHED_ID = 7303
    private const val RUNNING_CHANNEL = "focus_timer"
    private const val FINISHED_CHANNEL = "focus_complete"
    private fun prefs(context: Context) = context.getSharedPreferences("focus_notice", Context.MODE_PRIVATE)
    private fun manager(context: Context) = context.getSystemService(NotificationManager::class.java)
    private fun alarms(context: Context) = context.getSystemService(AlarmManager::class.java)

    fun allowed(context: Context): Boolean =
        (Build.VERSION.SDK_INT < 33 || context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
            manager(context).areNotificationsEnabled() &&
            (Build.VERSION.SDK_INT < 26 || listOf(RUNNING_CHANNEL, FINISHED_CHANNEL).all {
                manager(context).getNotificationChannel(it)?.importance != NotificationManager.IMPORTANCE_NONE
            })

    private fun exact(context: Context) = Build.VERSION.SDK_INT < 31 || alarms(context).canScheduleExactAlarms()

    private fun channels(context: Context) {
        if (Build.VERSION.SDK_INT >= 26) {
            manager(context).createNotificationChannel(NotificationChannel(RUNNING_CHANNEL, "专注计时 / Focus timer", NotificationManager.IMPORTANCE_LOW))
            manager(context).createNotificationChannel(NotificationChannel(FINISHED_CHANNEL, "专注完成 / Focus complete", NotificationManager.IMPORTANCE_HIGH).apply {
                enableVibration(true)
            })
        }
    }

    private fun alarmIntent(context: Context, key: String = "", deadline: Long = 0): PendingIntent =
        PendingIntent.getBroadcast(context, RUNNING_ID,
            Intent(context, FocusAlarmReceiver::class.java).setAction("com.innocence.FOCUS_COMPLETE")
                .putExtra("key", key).putExtra("deadline", deadline),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

    private fun builder(context: Context, channel: String): Notification.Builder =
        (if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, channel) else Notification.Builder(context))
            .setSmallIcon(R.drawable.ic_focus_notice)
            .setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(PendingIntent.getActivity(context, FINISHED_ID,
                Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))

    fun sync(context: Context, owner: String, key: String, active: Boolean, paused: Boolean,
             deadline: Long, remaining: Int, completed: Boolean, chinese: Boolean): String {
        channels(context)
        val saved = prefs(context)
        if (completed && key.isNotEmpty()) {
            if (saved.getString("key", "") == key) complete(context, key, saved.getLong("deadline", 0))
            return if (allowed(context)) "available" else "permissionRequired"
        }
        alarms(context).cancel(alarmIntent(context))
        manager(context).cancel(RUNNING_ID)
        if (!active) {
            // A startup with no active row may follow expiry while the app was killed.
            if (key.isEmpty() && owner.isNotEmpty() && saved.getString("owner", "") == owner && saved.getBoolean("active", false) &&
                !saved.getBoolean("paused", false) && saved.getLong("deadline", Long.MAX_VALUE) <= System.currentTimeMillis()) {
                complete(context, saved.getString("key", "") ?: "", saved.getLong("deadline", 0))
            }
            check(saved.edit().putBoolean("active", false).commit())
            if (owner.isEmpty() || saved.getString("owner", "") != owner) manager(context).cancel(FINISHED_ID)
            return "available"
        }
        if (saved.getString("key", "") != key) manager(context).cancel(FINISHED_ID)
        check(saved.edit().putString("owner", owner).putString("key", key).putBoolean("active", true).putBoolean("paused", paused)
            .putLong("deadline", deadline).putInt("remaining", remaining).putBoolean("chinese", chinese).commit())
        if (!allowed(context)) return "permissionRequired"
        if (!paused && deadline <= System.currentTimeMillis()) {
            complete(context, key, deadline)
            return "available"
        }
        val text = if (paused) {
            (if (chinese) "剩余 " else "Remaining ") + formatSeconds(remaining)
        } else if (chinese) "点击返回专注" else "Tap to return to focus"
        val notice = builder(context, RUNNING_CHANNEL)
            .setContentTitle(if (chinese) (if (paused) "专注已暂停" else "专注倒计时") else (if (paused) "Focus paused" else "Focus countdown"))
            .setContentText(text).setOngoing(true).setOnlyAlertOnce(true)
            .setWhen(deadline).setShowWhen(!paused).setUsesChronometer(!paused && Build.VERSION.SDK_INT >= 24)
        if (Build.VERSION.SDK_INT >= 24) notice.setChronometerCountDown(true)
        manager(context).notify(RUNNING_ID, notice.build())
        if (!paused) {
            val alarm = alarmIntent(context, key, deadline)
            if (exact(context)) alarms(context).setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, deadline, alarm)
            else alarms(context).setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, deadline, alarm)
        }
        return if (exact(context) || paused) "available" else "exactPermissionRequired"
    }

    fun complete(context: Context, key: String, deadline: Long) {
        val saved = prefs(context)
        if (key.isEmpty() || saved.getString("key", "") != key || saved.getLong("deadline", 0) != deadline ||
            !saved.getBoolean("active", false) || saved.getBoolean("paused", false) ||
            saved.getString("completed", "") == key || deadline > System.currentTimeMillis()) return
        alarms(context).cancel(alarmIntent(context))
        manager(context).cancel(RUNNING_ID)
        check(saved.edit().putString("completed", key).putBoolean("active", false).commit())
        if (!allowed(context)) return
        channels(context)
        val chinese = saved.getBoolean("chinese", true)
        manager(context).notify(FINISHED_ID, builder(context, FINISHED_CHANNEL)
            .setContentTitle(if (chinese) "专注计时已完成" else "Focus timer complete")
            .setContentText(if (chinese) "本次倒计时已到点，休息一下吧。" else "Your countdown has ended. Take a break.")
            .setAutoCancel(true).setOnlyAlertOnce(true).build())
    }

    fun restore(context: Context) {
        val saved = prefs(context)
        if (!saved.getBoolean("active", false)) return
        sync(context, saved.getString("owner", "") ?: "", saved.getString("key", "") ?: "", true, saved.getBoolean("paused", false),
            saved.getLong("deadline", 0), saved.getInt("remaining", 0), false, saved.getBoolean("chinese", true))
    }

    private fun formatSeconds(seconds: Int): String =
        if (seconds >= 3600) "%02d:%02d:%02d".format(seconds / 3600, seconds / 60 % 60, seconds % 60)
        else "%02d:%02d".format(seconds / 60, seconds % 60)
}

class FocusAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            if (intent.action == "com.innocence.FOCUS_COMPLETE") {
                FocusNotices.complete(context, intent.getStringExtra("key") ?: "", intent.getLongExtra("deadline", 0))
            } else if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
                intent.action == AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED) {
                FocusNotices.restore(context)
            }
        } catch (_: Exception) {
            // No account, task content, or native arguments in system logs.
        }
    }
}
