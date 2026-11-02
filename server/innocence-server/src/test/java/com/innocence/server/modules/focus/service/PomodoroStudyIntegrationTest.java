package com.innocence.server.modules.focus.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.modules.focus.dto.request.PomodoroStudyRequest;
import com.innocence.server.modules.focus.dto.request.StartFocusSessionRequest;
import com.innocence.server.modules.stats.service.StatsService;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import java.time.*;
import java.util.UUID;
import static org.junit.jupiter.api.Assertions.*;

/** Real MySQL unique-key and aggregate checks; all synthetic business data rolls back. */
@SpringBootTest(properties = "logging.level.com.innocence.server=INFO")
@Transactional
class PomodoroStudyIntegrationTest {
    @Autowired FocusSessionService focus;
    @Autowired StatsService stats;
    @Autowired JdbcTemplate db;
    long owner;
    LocalDateTime start = LocalDate.now().minusDays(1).atTime(10, 0);
    String key = "qa_" + UUID.randomUUID().toString().replace("-", "") + "/1/" + start.toLocalDate();
    @BeforeEach void setup() { owner = createOwner(); }
    long createOwner() {
        String marker = "pomodoro-fixture-" + UUID.randomUUID();
        db.update("INSERT INTO app_user(user_no,nickname,status) VALUES(?,?,1)",
            UUID.randomUUID().toString().replace("-", ""), marker);
        return db.queryForObject("SELECT id FROM app_user WHERE nickname=?", Long.class, marker);
    }
    PomodoroStudyRequest request(int credit, int rounds) {
        return new PomodoroStudyRequest(key, start, start.plusMinutes(2), 120, credit, rounds);
    }
    @Test void manualBoundEnvelopeNeverAddsWallTimeOrDuplicatesPomodoroStudy() {
        var input = new StartFocusSessionRequest(); input.setDurationMinutes(60);
        input.setEndTime(LocalDateTime.now().plusHours(1)); input.setBindPomodoro(true); input.setManualPomodoro(true);
        input.setPomodoroStudyMinutes(1); input.setPomodoroBreakMinutes(1);
        var current = focus.startSession(owner, input);
        assertTrue(current.isManualPomodoro()); assertTrue(current.isBindPomodoro());
        db.update("UPDATE study_timer_record SET create_time=DATE_SUB(NOW(), INTERVAL 4 MINUTE) WHERE id=?",current.getSessionId());
        focus.recordPomodoroStudy(owner, request(120, 1));
        var finish = new com.innocence.server.modules.focus.dto.request.FinishFocusSessionRequest(); finish.setSessionId(current.getSessionId());
        focus.finishSession(owner, finish);
        focus.recordPomodoroStudy(owner, request(120, 1));
        assertEquals(0, db.queryForObject("SELECT duration_seconds FROM study_timer_record WHERE id=?", Integer.class, current.getSessionId()));
        assertEquals(2, stats.getOverview(owner, 7).getTotalStudyDurationMinutes());
        assertEquals(1, stats.getOverview(owner, 7).getTotalPomodoroCompleted());
    }
    @Test void retriesAndOlderSnapshotsNeverDoubleCountAndBreakCompletesOnlyTheRound() {
        focus.recordPomodoroStudy(owner, request(60, 0));
        focus.recordPomodoroStudy(owner, request(60, 0));
        assertEquals(1, stats.getOverview(owner, 7).getTotalStudyDurationMinutes());
        assertEquals(0, stats.getOverview(owner, 7).getTotalPomodoroCompleted());
        focus.recordPomodoroStudy(owner, request(60, 1));
        focus.recordPomodoroStudy(owner, request(30, 0));
        assertEquals(1, stats.getOverview(owner, 7).getTotalStudyDurationMinutes());
        assertEquals(1, stats.getOverview(owner, 7).getTotalPomodoroCompleted());
        assertEquals(1, db.queryForObject("SELECT COUNT(*) FROM study_timer_record WHERE user_id=?", Integer.class, owner));
    }
    @Test void sameClientKeyIsIsolatedByAuthenticatedOwner() {
        long other = createOwner();
        focus.recordPomodoroStudy(owner, request(60, 1));
        assertEquals(0, stats.getOverview(other, 7).getTotalStudyDurationMinutes());
        focus.recordPomodoroStudy(other, request(120, 0));
        assertEquals(1, stats.getOverview(owner, 7).getTotalStudyDurationMinutes());
        assertEquals(2, stats.getOverview(other, 7).getTotalStudyDurationMinutes());
        assertEquals(0, stats.getOverview(other, 7).getTotalPomodoroCompleted());
    }
    @Test void missingFieldsFutureTimeAndInflatedCreditCannotWrite() {
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(owner,
            new PomodoroStudyRequest(key, start, start.plusMinutes(2), null, 60, 1)));
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(owner, request(121, 1)));
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(owner, request(60, 2)));
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(null, request(60, 1)));
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(owner,
            new PomodoroStudyRequest(key, start, start.plusSeconds(10), 120, 60, 1)));
        var future = LocalDate.now().plusDays(1).atTime(10, 0);
        assertThrows(BusinessException.class, () -> focus.recordPomodoroStudy(owner,
            new PomodoroStudyRequest("future/1/" + future.toLocalDate(), future, future.plusMinutes(1), 60, 60, 0)));
        assertEquals(0, db.queryForObject("SELECT COUNT(*) FROM study_timer_record WHERE user_id=?", Integer.class, owner));
    }
    @Test void oneMinuteCustomFocusUsesServerClockDespiteNetworkDelay() {
        var request = new StartFocusSessionRequest();
        request.setEndTime(LocalDateTime.now().plusSeconds(55));
        request.setDurationMinutes(1);
        var session = focus.startSession(owner, request);
        assertEquals(60, session.getRemainingSeconds());
        assertEquals(1, session.getPlannedMinutes());
    }
}
