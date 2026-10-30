package com.innocence.app.innocence_flutter

import android.app.Notification
import android.content.Context
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import java.util.Locale

/** System UI owns the ticking view, including when the Flutter process is absent. */
internal object TimerNoticeContent {
    fun apply(context: Context, builder: Notification.Builder, title: String, deadline: Long,
              remainingSeconds: Long, paused: Boolean, chinese: Boolean): Notification.Builder {
        val remainingMs = maxOf(0L, deadline - System.currentTimeMillis())
        val seconds = if (paused) remainingSeconds else (remainingMs + 999) / 1000
        val duration = formatSeconds(seconds)
        val views = RemoteViews(context.packageName, R.layout.timer_notice).apply {
            setTextViewText(R.id.timer_notice_title, title)
            setViewVisibility(R.id.timer_notice_countdown, if (paused) View.GONE else View.VISIBLE)
            setViewVisibility(R.id.timer_notice_paused, if (paused) View.VISIBLE else View.GONE)
            setTextViewText(R.id.timer_notice_paused, duration)
            setChronometerCountDown(R.id.timer_notice_countdown, true)
            setChronometer(R.id.timer_notice_countdown, SystemClock.elapsedRealtime() + remainingMs, null, !paused)
        }
        return builder.setContentTitle(title)
            // Also supply meaningful text to notification readers and alternative system templates.
            .setContentText((if (chinese) "剩余 " else "Remaining ") + duration)
            .setWhen(deadline).setShowWhen(false).setUsesChronometer(!paused).setChronometerCountDown(true)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(views).setCustomBigContentView(views)
    }

    private fun formatSeconds(seconds: Long): String =
        if (seconds >= 3600) String.format(Locale.ROOT, "%02d:%02d:%02d", seconds / 3600, seconds / 60 % 60, seconds % 60)
        else String.format(Locale.ROOT, "%02d:%02d", seconds / 60, seconds % 60)
}
