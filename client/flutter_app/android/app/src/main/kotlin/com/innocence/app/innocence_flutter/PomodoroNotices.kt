package com.innocence.app.innocence_flutter

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

internal data class IndependentPomodoro(val owner: String, val key: String, val active: Boolean,
    val paused: Boolean, val study: Int, val rest: Int, val elapsed: Long, val reference: Long, val chinese: Boolean) {
    companion object {
        fun parse(value: Any?): IndependentPomodoro {
            val map = value as? Map<*, *> ?: throw IllegalArgumentException()
            fun number(name: String): Long {
                val v = map[name] as? Number ?: throw IllegalArgumentException()
                require(v.toDouble().isFinite() && v.toDouble() == v.toLong().toDouble())
                return v.toLong()
            }
            val owner = map["owner"] as? String ?: throw IllegalArgumentException()
            val key = map["key"] as? String ?: throw IllegalArgumentException()
            val active = map["active"] as? Boolean ?: throw IllegalArgumentException()
            val paused = map["paused"] as? Boolean ?: throw IllegalArgumentException()
            val chinese = map["isChinese"] as? Boolean ?: throw IllegalArgumentException()
            val study = number("studyMinutes"); val rest = number("breakMinutes")
            val elapsed = number("elapsedMs"); val reference = number("referenceMs")
            require(owner.length <= 128 && key.length <= 256 && study in 1..1440 && rest in 0..1440)
            require(elapsed in 0..3155760000000L && reference in 0..9007199254740991L)
            require(key.isEmpty() || (owner.isNotEmpty() && key.startsWith("$owner/pomodoro/")))
            require(!active || (key.isNotEmpty() && reference > 0))
            return IndependentPomodoro(owner, key, active, paused, study.toInt(), rest.toInt(), elapsed, reference, chinese)
        }
    }
}

/** Independent clock/prefs/alarm IDs: focus completion cannot cancel this timer. */
internal object PomodoroNotices {
    private const val TIMER_ID = 7305
    private const val STAGE_ID = 7306
    private const val TIMER_CHANNEL = "independent_pomodoro"
    private const val STAGE_CHANNEL = "pomodoro_stage"
    private fun prefs(c: Context) = c.getSharedPreferences("independent_pomodoro", Context.MODE_PRIVATE)
    private fun manager(c: Context) = c.getSystemService(NotificationManager::class.java)
    private fun alarms(c: Context) = c.getSystemService(AlarmManager::class.java)
    private fun alarm(c: Context, key: String = "", deadline: Long = 0) = PendingIntent.getBroadcast(c, TIMER_ID,
        Intent(c, FocusAlarmReceiver::class.java).setAction("com.innocence.INDEPENDENT_POMODORO")
            .putExtra("key", key).putExtra("deadline", deadline),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    private fun exact(c: Context) = Build.VERSION.SDK_INT < 31 || alarms(c).canScheduleExactAlarms()
    fun allowed(c: Context) =
        (Build.VERSION.SDK_INT < 33 || c.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) &&
        manager(c).areNotificationsEnabled() && (Build.VERSION.SDK_INT < 26 || listOf(TIMER_CHANNEL, STAGE_CHANNEL).all {
            manager(c).getNotificationChannel(it)?.importance != NotificationManager.IMPORTANCE_NONE
        })
    private fun channels(c: Context) {
        if (Build.VERSION.SDK_INT < 26) return
        manager(c).createNotificationChannel(NotificationChannel(TIMER_CHANNEL, "独立番茄计时 / Pomodoro timer", NotificationManager.IMPORTANCE_LOW))
        manager(c).createNotificationChannel(NotificationChannel(STAGE_CHANNEL, "番茄阶段提醒 / Pomodoro stages", NotificationManager.IMPORTANCE_HIGH))
    }
    private fun builder(c: Context, channel: String) =
        (if (Build.VERSION.SDK_INT >= 26) Notification.Builder(c, channel) else Notification.Builder(c))
            .setSmallIcon(R.drawable.ic_focus_notice).setCategory(Notification.CATEGORY_ALARM)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(PendingIntent.getActivity(c, TIMER_ID,
                Intent(c, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))

    fun sync(c: Context, timer: IndependentPomodoro): String {
        channels(c)
        val saved = prefs(c)
        val oldKey = saved.getString("key", "")
        alarms(c).cancel(alarm(c))
        if (!timer.active || oldKey != timer.key) {
            manager(c).cancel(TIMER_ID); manager(c).cancel(STAGE_ID)
        }
        check(saved.edit().putString("owner", timer.owner).putString("key", timer.key).putBoolean("active", timer.active)
            .putBoolean("paused", timer.paused).putInt("study", timer.study).putInt("rest", timer.rest)
            .putLong("elapsed", timer.elapsed).putLong("reference", timer.reference).putBoolean("chinese", timer.chinese).commit())
        if (!timer.active) return "available"
        update(c)
        return if (!allowed(c)) "permissionRequired" else if (!timer.paused && !exact(c)) "exactPermissionRequired" else "available"
    }

    fun update(c: Context, expectedKey: String = "", expectedDeadline: Long = 0) {
        val saved = prefs(c)
        if (!saved.getBoolean("active", false)) return
        val key = saved.getString("key", "") ?: ""
        if (expectedKey.isNotEmpty() && (key != expectedKey || expectedDeadline != saved.getLong("deadline", 0))) return
        val paused = saved.getBoolean("paused", false)
        val now = System.currentTimeMillis()
        val elapsed = saved.getLong("elapsed", 0) + if (paused) 0 else maxOf(0, now - saved.getLong("reference", now))
        val study = saved.getInt("study", 25) * 60000L
        val rest = saved.getInt("rest", 5) * 60000L
        if (study <= 0 || rest < 0) return
        val period = study + rest
        val position = elapsed % period
        val resting = rest > 0 && position >= study
        val cycle = elapsed / period + 1
        val remaining = (if (resting) period else study) - position
        val deadline = now + remaining
        val token = "$key/$cycle/$resting"
        val chinese = saved.getBoolean("chinese", true)
        val title = if (chinese) "番茄 · ${if (resting) "休息" else "学习"}${if (paused) " · 已暂停" else ""}"
            else "Pomodoro · ${if (resting) "Break" else "Study"}${if (paused) " · Paused" else ""}"
        val seconds = (remaining + 999) / 1000
        val label = if (seconds >= 3600) "%02d:%02d:%02d".format(seconds / 3600, seconds / 60 % 60, seconds % 60)
            else "%02d:%02d".format(seconds / 60, seconds % 60)
        val text = (if (chinese) "第 $cycle 轮" else "Cycle $cycle") + if (paused) " · $label" else ""
        val previous = saved.getString("stageToken", "") ?: ""
        check(saved.edit().putLong("deadline", deadline).putString("stageToken", token).commit())
        if (allowed(c)) {
            val notice = builder(c, TIMER_CHANNEL).setContentTitle(title).setContentText(text)
                .setOngoing(true).setOnlyAlertOnce(true).setWhen(deadline).setShowWhen(!paused).setUsesChronometer(!paused)
            if (Build.VERSION.SDK_INT >= 24) notice.setChronometerCountDown(true)
            manager(c).notify(TIMER_ID, notice.build())
            if (!paused && previous.isNotEmpty() && previous != token && previous.startsWith("$key/")) {
                manager(c).notify(STAGE_ID, builder(c, STAGE_CHANNEL).setContentTitle(title)
                    .setContentText(if (chinese) "上一阶段已结束，开始${if (resting) "休息" else "学习"}。" else "The next pomodoro stage has started.")
                    .setAutoCancel(true).build())
            }
        }
        if (!paused) {
            val pending = alarm(c, key, deadline)
            if (exact(c)) alarms(c).setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, deadline, pending)
            else alarms(c).setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, deadline, pending)
        }
    }
}
