package com.innocence.server.modules.checkin.service;

import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.checkin.domain.CheckInFailRecord;
import com.innocence.server.modules.checkin.domain.CheckInRecord;
import com.innocence.server.modules.checkin.domain.CheckInSummary;
import com.innocence.server.modules.checkin.dto.response.CheckInStatusResponse;
import com.innocence.server.modules.checkin.dto.response.CheckInSubmitResponse;
import com.innocence.server.modules.checkin.mapper.CheckInMapper;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.service.StudyPlanService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
public class CheckInService {

    private final CheckInMapper checkInMapper;
    private final StudyPlanService studyPlanService;
    private final UserMapper userMapper;
    private final NotificationService notificationService;

    public CheckInService(
            CheckInMapper checkInMapper,
            StudyPlanService studyPlanService,
            UserMapper userMapper,
            NotificationService notificationService
    ) {
        this.checkInMapper = checkInMapper;
        this.studyPlanService = studyPlanService;
        this.userMapper = userMapper;
        this.notificationService = notificationService;
    }

    @Transactional(readOnly = true)
    public CheckInStatusResponse getTodayStatus(Long userId) {
        return buildTodayStatus(userId, LocalDate.now());
    }

    @Transactional
    public CheckInSubmitResponse submitTodayCheckIn(Long userId) {
        LocalDate today = LocalDate.now();
        CheckInRecord existingRecord = checkInMapper.findCheckInRecordByUserIdAndDate(userId, today);
        if (existingRecord != null) {
            return buildSubmitResponse(
                    true,
                    "Today's check-in is already complete.",
                    buildTodayStatus(userId, today)
            );
        }

        TodayPlanResponse todayPlan = studyPlanService.getTodayPlan(userId, today);
        int totalStudyDurationMinutes = resolveTotalStudyDurationMinutes(userId);
        String failureMessage = resolveCheckInFailureMessage(todayPlan);
        if (failureMessage != null) {
            CheckInFailRecord previousFailRecord =
                    checkInMapper.findCheckInFailRecordByUserIdAndDate(userId, today);
            recordFailure(userId, today, todayPlan, totalStudyDurationMinutes, failureMessage);
            if (previousFailRecord == null) {
                notificationService.createCheckInResultNotification(userId, false, failureMessage);
            }
            return buildSubmitResponse(
                    false,
                    failureMessage,
                    buildTodayStatus(userId, today)
            );
        }

        CheckInRecord record = new CheckInRecord();
        record.setUserId(userId);
        record.setCheckInDate(today);
        record.setPlanCompletedCount(todayPlan.getCompletedCount());
        record.setPlanTotalCount(todayPlan.getTotalCount());
        record.setStudyDurationMinutes(totalStudyDurationMinutes);
        checkInMapper.insertCheckInRecord(record);

        updateSummaryOnSuccess(userId, today);
        notificationService.createCheckInResultNotification(
                userId,
                true,
                "Today's check-in completed. Great work."
        );

        return buildSubmitResponse(
                true,
                "Today's check-in completed. Great work.",
                buildTodayStatus(userId, today)
        );
    }

    @Transactional(readOnly = true)
    public int getTotalCheckInDays(Long userId) {
        CheckInSummary summary = checkInMapper.findCheckInSummaryByUserId(userId);
        if (summary != null && summary.getTotalDays() != null) {
            return Math.max(summary.getTotalDays(), 0);
        }
        Integer count = checkInMapper.countCheckInRecordsByUserId(userId);
        return count == null ? 0 : Math.max(count, 0);
    }

    @Transactional
    public boolean deleteFailureRecord(Long userId, LocalDate checkInDate) {
        if (checkInDate == null) {
            return false;
        }
        return checkInMapper.deleteCheckInFailRecordByUserIdAndDate(userId, checkInDate) > 0;
    }

    private CheckInStatusResponse buildTodayStatus(Long userId, LocalDate today) {
        TodayPlanResponse todayPlan = studyPlanService.getTodayPlan(userId, today);
        CheckInRecord todayRecord = checkInMapper.findCheckInRecordByUserIdAndDate(userId, today);
        CheckInFailRecord todayFailRecord = checkInMapper.findCheckInFailRecordByUserIdAndDate(userId, today);
        CheckInSummary summary = checkInMapper.findCheckInSummaryByUserId(userId);
        int totalStudyDurationMinutes = resolveTotalStudyDurationMinutes(userId);

        boolean checkedInToday = todayRecord != null;
        boolean todayPlanCompleted = isTodayPlanCompleted(todayPlan);

        CheckInStatusResponse response = new CheckInStatusResponse();
        response.setCheckInDate(today.toString());
        response.setCheckedInToday(checkedInToday);
        response.setCanCheckInToday(!checkedInToday && todayPlanCompleted);
        response.setTodayPlanCompleted(todayPlanCompleted);
        response.setTodayPlanCompletedCount(todayPlan.getCompletedCount());
        response.setTodayPlanTotalCount(todayPlan.getTotalCount());
        response.setConsecutiveDays(resolveVisibleConsecutiveDays(summary, today, checkedInToday));
        response.setTotalDays(resolveTotalDays(userId, summary));
        response.setTotalStudyDurationMinutes(totalStudyDurationMinutes);
        response.setTodayFailedAttempts(todayFailRecord == null ? 0 : defaultNumber(todayFailRecord.getAttemptCount()));
        response.setLatestFailureReason(todayFailRecord == null ? "" : defaultString(todayFailRecord.getLatestReason()));
        response.setLastCheckInTime(todayRecord == null ? "" : formatDateTime(todayRecord.getCreateTime()));
        response.setLastFailureTime(todayFailRecord == null ? "" : formatDateTime(todayFailRecord.getLastAttemptTime()));
        return response;
    }

    private CheckInSubmitResponse buildSubmitResponse(
            boolean success,
            String message,
            CheckInStatusResponse status
    ) {
        CheckInSubmitResponse response = new CheckInSubmitResponse();
        response.setSuccess(success);
        response.setMessage(message);
        response.setStatus(status);
        return response;
    }

    private void recordFailure(
            Long userId,
            LocalDate checkInDate,
            TodayPlanResponse todayPlan,
            int totalStudyDurationMinutes,
            String message
    ) {
        CheckInFailRecord failRecord = new CheckInFailRecord();
        failRecord.setUserId(userId);
        failRecord.setCheckInDate(checkInDate);
        failRecord.setAttemptCount(1);
        failRecord.setLatestReason(message);
        failRecord.setPlanCompletedCount(todayPlan.getCompletedCount());
        failRecord.setPlanTotalCount(todayPlan.getTotalCount());
        failRecord.setStudyDurationMinutes(totalStudyDurationMinutes);
        failRecord.setLastAttemptTime(LocalDateTime.now());
        checkInMapper.upsertCheckInFailRecord(failRecord);
    }

    private void updateSummaryOnSuccess(Long userId, LocalDate today) {
        CheckInSummary summary = checkInMapper.findCheckInSummaryByUserId(userId);
        if (summary == null) {
            CheckInSummary newSummary = new CheckInSummary();
            newSummary.setUserId(userId);
            newSummary.setConsecutiveDays(1);
            newSummary.setTotalDays(1);
            newSummary.setLastSuccessDate(today);
            checkInMapper.insertCheckInSummary(newSummary);
            return;
        }

        LocalDate lastSuccessDate = summary.getLastSuccessDate();
        boolean alreadyRecordedToday = lastSuccessDate != null && lastSuccessDate.isEqual(today);
        int currentConsecutiveDays = defaultNumber(summary.getConsecutiveDays());
        int currentTotalDays = defaultNumber(summary.getTotalDays());

        int nextConsecutiveDays;
        if (alreadyRecordedToday) {
            nextConsecutiveDays = Math.max(currentConsecutiveDays, 1);
        } else if (lastSuccessDate != null && lastSuccessDate.plusDays(1).isEqual(today)) {
            nextConsecutiveDays = currentConsecutiveDays + 1;
        } else {
            nextConsecutiveDays = 1;
        }

        summary.setConsecutiveDays(nextConsecutiveDays);
        summary.setTotalDays(alreadyRecordedToday ? currentTotalDays : currentTotalDays + 1);
        summary.setLastSuccessDate(today);
        checkInMapper.updateCheckInSummary(summary);
    }

    private String resolveCheckInFailureMessage(TodayPlanResponse todayPlan) {
        if (todayPlan.getTotalCount() <= 0) {
            return "Create today's plan first, then try check-in.";
        }
        if (!isTodayPlanCompleted(todayPlan)) {
            return "Finish all today's plan items before check-in.";
        }
        return null;
    }

    private boolean isTodayPlanCompleted(TodayPlanResponse todayPlan) {
        return todayPlan.getTotalCount() > 0
                && todayPlan.getCompletedCount() >= todayPlan.getTotalCount();
    }

    private int resolveVisibleConsecutiveDays(CheckInSummary summary, LocalDate today, boolean checkedInToday) {
        if (summary == null || summary.getLastSuccessDate() == null) {
            return checkedInToday ? 1 : 0;
        }

        LocalDate lastSuccessDate = summary.getLastSuccessDate();
        if (lastSuccessDate.isEqual(today)) {
            return Math.max(defaultNumber(summary.getConsecutiveDays()), 1);
        }
        if (lastSuccessDate.plusDays(1).isEqual(today)) {
            return Math.max(defaultNumber(summary.getConsecutiveDays()), 0);
        }
        return 0;
    }

    private int resolveTotalDays(Long userId, CheckInSummary summary) {
        if (summary != null && summary.getTotalDays() != null) {
            return Math.max(summary.getTotalDays(), 0);
        }
        Integer count = checkInMapper.countCheckInRecordsByUserId(userId);
        return count == null ? 0 : Math.max(count, 0);
    }

    private int resolveTotalStudyDurationMinutes(Long userId) {
        Integer totalStudySeconds = userMapper.findTotalStudySecondsByUserId(userId);
        return (totalStudySeconds == null ? 0 : Math.max(totalStudySeconds, 0)) / 60;
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private String formatDateTime(LocalDateTime value) {
        return value == null ? "" : value.toString();
    }
}
