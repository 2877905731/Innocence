package com.innocence.app.innocence_flutter

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.app.Instrumentation
import android.os.Bundle
import android.os.SystemClock
import android.view.View
import android.widget.Chronometer
import android.widget.FrameLayout
import android.widget.TextView

/** Device checks use private synthetic notification state, never business SQLite. */
class FocusNoticeNativeTest : Instrumentation() {
    private lateinit var app: Context
    private lateinit var manager: NotificationManager
    private var mode = "normal"

    override fun onCreate(arguments: Bundle?) {
        super.onCreate(arguments)
        mode = arguments?.getString("mode") ?: "normal"
        start()
    }

    override fun onStart() {
        var currentTest = "setup"
        val tests = listOf(
            "countdown_pause_resume_early_finish" to ::testCountdownPauseResumeAndEarlyFinish,
            "system_alarm_once_without_flutter" to ::testSystemAlarmCompletesOnceWithoutFlutterTicker,
            "stale_session_tenant_mismatch" to ::testStaleSessionAndTenantMismatchDoNotAlert,
            "missing_field_invalid_identity" to ::testMissingFieldAndInvalidIdentity,
            "pomodoro_stage_pause_restore_unbind" to ::testPomodoroStagePauseRestoreAndUnbind,
            "pomodoro_missing_fields_and_total_completion" to ::testPomodoroValidationAndCompletion,
            "independent_stage_survives_focus_end" to ::testIndependentStageSurvivesFocusEnd,
            "independent_pause_restore_owner_cancel" to ::testIndependentPauseRestoreOwnerCancel,
            "independent_payload_validation" to ::testIndependentPayloadValidation,
            "countdown_body_running_paused_hours_languages" to ::testCountdownBodyViews,
        )
        try {
            if (mode in listOf("countdownPreview", "pausedPreview", "englishPreview", "cleanup")) {
                app = targetContext
                check(app.packageName.endsWith(".focusqa"))
                manager = app.getSystemService(NotificationManager::class.java)
                tearDown()
                if (mode != "cleanup") {
                    val paused = mode == "pausedPreview"
                    val chinese = mode != "englishPreview"
                    val now = System.currentTimeMillis()
                    FocusNotices.sync(app, "qa", "qa/preview", true, paused, now + 5400000, 5400, false, chinese)
                    PomodoroNotices.sync(app, IndependentPomodoro("qa", "qa/pomodoro/preview", true, paused,
                        25, 5, 0, now, chinese))
                    awaitNotice(7302)
                    awaitNotice(7305)
                }
                finish(-1, Bundle().apply { putString("stream", "$mode: PASS\n") })
                return
            }
            if (mode == "backgroundArm") {
                setUp()
                FocusNotices.sync(app, "qa", "qa/background", true, false, System.currentTimeMillis() + 10000, 10, false, true)
                awaitNotice(7302)
                finish(-1, Bundle().apply { putString("stream", "Background alarm armed: PASS\n") })
                return
            }
            if (mode == "denied") {
                app = targetContext
                manager = app.getSystemService(NotificationManager::class.java)
                assertFalse(FocusNotices.allowed(app))
                assertEquals("permissionRequired", FocusNotices.sync(app, "qa", "qa/denied", true, false, System.currentTimeMillis() + 60000, 60, false, true))
                assertEquals("permissionRequired", PomodoroNotices.sync(app, IndependentPomodoro("qa", "qa/pomodoro/denied", true,
                    false, 1, 1, 0, System.currentTimeMillis(), true)))
                awaitAbsent(7302, 7303, 7304, 7305, 7306)
                tearDown()
                finish(-1, Bundle().apply { putString("stream", "Denied notification permission: PASS\n") })
                return
            }
            for ((name, test) in tests) {
                currentTest = name
                setUp()
                try { test() } finally { tearDown() }
                sendStatus(0, Bundle().apply { putString("stream", "$name: PASS\n") })
            }
            finish(-1, Bundle().apply { putString("stream", "OK (${tests.size} native timer checks)\n") })
        } catch (error: Throwable) {
            finish(0, Bundle().apply { putString("stream", "FAIL $currentTest: ${error.javaClass.simpleName} at ${error.stackTrace.firstOrNull { it.className.endsWith("FocusNoticeNativeTest") }}\n") })
        }
    }

    private fun setUp() {
        app = targetContext
        manager = app.getSystemService(NotificationManager::class.java)
        val saved = app.getSharedPreferences("focus_notice", Context.MODE_PRIVATE)
        // Never replace an existing real timer. Use a dedicated QA emulator.
        check(!saved.getBoolean("active", false))
        assertTrue("Grant POST_NOTIFICATIONS on the QA emulator", FocusNotices.allowed(app))
    }

    private fun tearDown() {
        PomodoroNotices.sync(app, IndependentPomodoro("", "", false, false, 25, 5, 0, 0, true))
        app.getSharedPreferences("independent_pomodoro", Context.MODE_PRIVATE).edit().clear().commit()
        FocusNotices.sync(app, "", "", false, false, 0, 0, false, true)
        app.getSharedPreferences("focus_notice", Context.MODE_PRIVATE).edit().clear().commit()
    }

    private fun assertTrue(value: Boolean) { check(value) }
    private fun assertTrue(message: String, value: Boolean) { check(value) { message } }
    private fun assertFalse(value: Boolean) { check(!value) }
    private fun assertEquals(expected: Any?, actual: Any?) { check(expected == actual) }
    private fun awaitNotice(id: Int, predicate: (Notification) -> Boolean = { true }): android.service.notification.StatusBarNotification {
        val until = System.currentTimeMillis() + 15000
        while (System.currentTimeMillis() < until) {
            manager.activeNotifications.firstOrNull { it.id == id && predicate(it.notification) }?.let { return it }
            Thread.sleep(50)
        }
        error("Expected timer notification")
    }
    private fun awaitAbsent(vararg ids: Int) {
        val until = System.currentTimeMillis() + 3000
        while (manager.activeNotifications.any { it.id in ids } && System.currentTimeMillis() < until) Thread.sleep(50)
        assertTrue(manager.activeNotifications.none { it.id in ids })
    }

    fun testMissingFieldAndInvalidIdentity() {
        val valid = mapOf<String, Any>("owner" to "qa", "key" to "qa/validation", "active" to true,
            "paused" to false, "deadlineMs" to (System.currentTimeMillis() + 60000),
            "remainingSeconds" to 60, "completed" to false, "isChinese" to true)
        for (invalid in listOf(valid - "deadlineMs", valid + ("key" to "other/validation"),
            valid + ("remainingSeconds" to -1), valid + ("deadlineMs" to Double.NaN))) {
            var rejected = false
            try { FocusNoticeArguments.parse(invalid) } catch (_: IllegalArgumentException) { rejected = true }
            assertTrue(rejected)
        }
        awaitAbsent(7302, 7303)
    }

    fun testIndependentStageSurvivesFocusEnd() {
        PomodoroNotices.sync(app, IndependentPomodoro("qa", "qa/pomodoro/independent", true, false, 1, 1, 58000,
            System.currentTimeMillis(), true))
        val notice = awaitNotice(7305).notification
        assertTrue(notice.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        awaitNotice(7305) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 休息" }
        awaitNotice(7306)
        val deadline = System.currentTimeMillis() + 2000
        FocusNotices.sync(app, "qa", "qa/total", true, false, deadline, 2, false, true)
        awaitNotice(7303)
        awaitAbsent(7302)
        awaitNotice(7305)
        PomodoroNotices.update(app) // Simulate boot/restore without a Flutter engine.
        awaitNotice(7305) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 休息" }
    }

    fun testIndependentPauseRestoreOwnerCancel() {
        PomodoroNotices.sync(app, IndependentPomodoro("qa", "qa/pomodoro/pause", true, true, 1, 0, 59000,
            System.currentTimeMillis(), true))
        val pause = awaitNotice(7305) { !it.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER) }.notification
        assertEquals("剩余 00:01", pause.extras.getString(Notification.EXTRA_TEXT))
        Thread.sleep(1500)
        PomodoroNotices.update(app)
        assertEquals("剩余 00:01", awaitNotice(7305).notification.extras.getString(Notification.EXTRA_TEXT))
        PomodoroNotices.sync(app, IndependentPomodoro("qa", "qa/pomodoro/pause", true, false, 1, 0, 59000,
            System.currentTimeMillis(), true))
        awaitNotice(7305) { it.`when` > System.currentTimeMillis() + 50000 }
        assertEquals("2", app.getSharedPreferences("independent_pomodoro", Context.MODE_PRIVATE)
            .getString("stageToken", "")?.split("/")?.get(3))
        val saved = app.getSharedPreferences("independent_pomodoro", Context.MODE_PRIVATE)
        val stale = saved.getLong("deadline", 0)
        PomodoroNotices.sync(app, IndependentPomodoro("other", "other/pomodoro/new", true, false, 25, 5, 0,
            System.currentTimeMillis(), true))
        PomodoroNotices.update(app, "qa/pomodoro/pause", stale)
        assertEquals("other/pomodoro/new", saved.getString("key", ""))
        PomodoroNotices.sync(app, IndependentPomodoro("", "", false, false, 25, 5, 0, 0, true))
        PomodoroNotices.update(app)
        awaitAbsent(7305, 7306)
    }

    fun testIndependentPayloadValidation() {
        val valid = mapOf<String, Any>("owner" to "qa", "key" to "qa/pomodoro/validation", "active" to true,
            "paused" to false, "studyMinutes" to 25, "breakMinutes" to 5, "elapsedMs" to 0,
            "referenceMs" to System.currentTimeMillis(), "isChinese" to true)
        assertTrue(IndependentPomodoro.parse(valid).active)
        for (bad in listOf(valid - "referenceMs", valid + ("studyMinutes" to 0), valid + ("owner" to "other"),
            valid + ("breakMinutes" to -1), valid + ("elapsedMs" to Double.NaN), valid + ("studyMinutes" to 1.5))) {
            var rejected = false
            try { IndependentPomodoro.parse(bad) } catch (_: IllegalArgumentException) { rejected = true }
            assertTrue(rejected)
        }
    }

    fun testCountdownPauseResumeAndEarlyFinish() {
        val deadline = System.currentTimeMillis() + 60000
        FocusNotices.sync(app, "qa", "qa/1", true, false, deadline, 60, false, true)
        val running = awaitNotice(7302) { it.`when` == deadline }.notification
        assertTrue(running.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        assertTrue(running.extras.getBoolean(Notification.EXTRA_CHRONOMETER_COUNT_DOWN))
        assertEquals(deadline, running.`when`)
        FocusNotices.sync(app, "qa", "qa/1", true, true, deadline, 58, false, true)
        val paused = awaitNotice(7302) { !it.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER) }.notification
        assertFalse(paused.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        assertEquals("剩余 00:58", paused.extras.getString(Notification.EXTRA_TEXT))
        val resumedDeadline = System.currentTimeMillis() + 58000
        FocusNotices.sync(app, "qa", "qa/1", true, false, resumedDeadline, 58, false, true)
        assertEquals(resumedDeadline, awaitNotice(7302) { it.`when` == resumedDeadline }.notification.`when`)
        FocusNotices.sync(app, "qa", "qa/1", false, false, resumedDeadline, 0, false, true)
        FocusNotices.complete(app, "qa/1", resumedDeadline)
        awaitAbsent(7302, 7303)
    }

    fun testSystemAlarmCompletesOnceWithoutFlutterTicker() {
        val deadline = System.currentTimeMillis() + 2500
        FocusNotices.sync(app, "qa", "qa/2", true, false, deadline, 3, false, true)
        val until = System.currentTimeMillis() + 15000
        while (manager.activeNotifications.none { it.id == 7303 } && System.currentTimeMillis() < until) Thread.sleep(100)
        val finished = awaitNotice(7303)
        assertEquals("专注计时已完成", finished.notification.extras.getString(Notification.EXTRA_TITLE))
        awaitAbsent(7302)
        FocusNotices.complete(app, "qa/2", deadline)
        assertEquals(finished.postTime, manager.activeNotifications.single { it.id == 7303 }.postTime)
    }

    fun testStaleSessionAndTenantMismatchDoNotAlert() {
        val oldDeadline = System.currentTimeMillis() + 2500
        FocusNotices.sync(app, "qa-a", "qa-a/3", true, false, oldDeadline, 3, false, true)
        val newDeadline = System.currentTimeMillis() + 60000
        FocusNotices.sync(app, "qa-b", "qa-b/3", true, false, newDeadline, 60, false, true)
        Thread.sleep(2700)
        FocusNotices.complete(app, "qa-a/3", oldDeadline)
        assertTrue(manager.activeNotifications.none { it.id == 7303 })
        assertTrue(manager.activeNotifications.any { it.id == 7302 })
        FocusNotices.sync(app, "", "", false, false, 0, 0, false, true)
        FocusNotices.complete(app, "qa-b/3", newDeadline)
        awaitAbsent(7302, 7303)
    }

    fun testPomodoroStagePauseRestoreAndUnbind() {
        val total = System.currentTimeMillis() + 90000
        val first = System.currentTimeMillis() + 2500
        FocusNotices.sync(app, "qa", "qa/pomodoro", true, false, total, 90, false, true,
            PomodoroNotice(1, 1, "study", 1, first, 3))
        val study = awaitNotice(7304) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 学习" }.notification
        assertTrue(study.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        awaitNotice(7304) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 休息" }
        FocusNotices.sync(app, "qa", "qa/pomodoro", true, true, total, 80, false, true,
            PomodoroNotice(1, 1, "break", 1, System.currentTimeMillis() + 3000, 3))
        val paused = awaitNotice(7304) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 休息 · 已暂停" }.notification
        assertFalse(paused.extras.getBoolean(Notification.EXTRA_SHOW_CHRONOMETER))
        assertEquals("剩余 00:03", paused.extras.getString(Notification.EXTRA_TEXT))
        Thread.sleep(3500)
        FocusNotices.restore(app)
        assertEquals("剩余 00:03", awaitNotice(7304).notification.extras.getString(Notification.EXTRA_TEXT))
        val resumed = System.currentTimeMillis() + 2500
        FocusNotices.sync(app, "qa", "qa/pomodoro", true, false, System.currentTimeMillis() + 80000, 80, false, true,
            PomodoroNotice(1, 1, "break", 1, resumed, 3))
        awaitNotice(7304) { it.extras.getString(Notification.EXTRA_TITLE) == "番茄 · 学习" }
        assertTrue(awaitNotice(7304).notification.extras.getString(Notification.EXTRA_TEXT)?.startsWith("剩余 ") == true)
        assertEquals(2, app.getSharedPreferences("focus_notice", Context.MODE_PRIVATE).getInt("pomodoroCycle", 0))
        FocusNotices.sync(app, "qa", "qa/pomodoro", true, false, System.currentTimeMillis() + 60000, 60, false, true)
        awaitAbsent(7304)
        awaitNotice(7302)
        FocusNotices.updatePomodoro(app, "qa/pomodoro", resumed)
        awaitAbsent(7304)
    }

    fun testPomodoroValidationAndCompletion() {
        val total = System.currentTimeMillis() + 3000
        val valid = mapOf<String, Any>("owner" to "qa", "key" to "qa/pomodoro-validation", "active" to true,
            "paused" to false, "deadlineMs" to total, "remainingSeconds" to 3, "completed" to false, "isChinese" to true,
            "bindPomodoro" to true, "pomodoroStudyMinutes" to 1, "pomodoroBreakMinutes" to 0,
            "pomodoroStage" to "study", "pomodoroCycle" to 1, "pomodoroDeadlineMs" to total, "pomodoroRemainingSeconds" to 3)
        assertTrue(FocusNoticeArguments.parse(valid).pomodoro != null)
        for (invalid in listOf(valid - "pomodoroStage", valid + ("pomodoroStudyMinutes" to 0),
            valid + ("pomodoroDeadlineMs" to total + 1), valid + ("pomodoroStage" to "break"))) {
            var rejected = false
            try { FocusNoticeArguments.parse(invalid) } catch (_: IllegalArgumentException) { rejected = true }
            assertTrue(rejected)
        }
        FocusNotices.sync(app, "qa", "qa/pomodoro-validation", true, false, total, 3, false, true,
            PomodoroNotice(1, 0, "study", 1, total, 3))
        awaitNotice(7304)
        awaitNotice(7303)
        awaitAbsent(7302, 7304)
    }

    fun testCountdownBodyViews() {
        for (chinese in listOf(true, false)) {
            for (paused in listOf(false, true)) {
                val deadline = System.currentTimeMillis() + 5400000
                val title = if (chinese) "专注倒计时" else "Focus countdown"
                val builder = Notification.Builder(app, "focus_timer").setSmallIcon(R.drawable.ic_focus_notice)
                val notice = TimerNoticeContent.apply(app, builder, title, deadline, 3661, paused, chinese).build()
                val text = notice.extras.getString(Notification.EXTRA_TEXT) ?: ""
                assertTrue(text.startsWith(if (chinese) "剩余 " else "Remaining "))
                assertFalse(text.contains("轮") || text.contains("Cycle"))
                if (paused) assertTrue(text.endsWith("01:01:01"))
                runOnMainSync {
                    for (remote in listOf(notice.contentView, notice.bigContentView)) {
                        check(remote != null)
                        val view = remote.apply(app, FrameLayout(app))
                        assertEquals(title, view.findViewById<TextView>(R.id.timer_notice_title).text.toString())
                        val countdown = view.findViewById<Chronometer>(R.id.timer_notice_countdown)
                        val frozen = view.findViewById<TextView>(R.id.timer_notice_paused)
                        assertEquals(if (paused) View.GONE else View.VISIBLE, countdown.visibility)
                        assertEquals(if (paused) View.VISIBLE else View.GONE, frozen.visibility)
                        if (paused) assertEquals("01:01:01", frozen.text.toString())
                        else {
                            assertTrue(countdown.isCountDown)
                            val expected = SystemClock.elapsedRealtime() + deadline - System.currentTimeMillis()
                            assertTrue(kotlin.math.abs(countdown.base - expected) < 250)
                        }
                    }
                }
            }
        }
    }
}
