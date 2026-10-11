package com.innocence.app.innocence_flutter

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.app.Instrumentation
import android.os.Bundle

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
        )
        try {
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
                awaitAbsent(7302, 7303)
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
            finish(-1, Bundle().apply { putString("stream", "OK (4 native timer checks)\n") })
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
}
