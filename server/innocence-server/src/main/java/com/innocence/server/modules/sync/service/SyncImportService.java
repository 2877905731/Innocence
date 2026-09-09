package com.innocence.server.modules.sync.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;
import com.innocence.server.modules.account.service.AccountService;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.focus.service.FocusSessionService;
import com.innocence.server.modules.memo.dto.request.SaveMemoRequest;
import com.innocence.server.modules.memo.dto.response.MemoCardResponse;
import com.innocence.server.modules.memo.service.MemoService;
import com.innocence.server.modules.plan.domain.AnnualPlanSegment;
import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplate;
import com.innocence.server.modules.plan.dto.request.SaveAnnualPlanSegmentRequest;
import com.innocence.server.modules.plan.dto.request.SaveTodayPlanRequest;
import com.innocence.server.modules.plan.dto.request.SaveWeeklyTemplateRequest;
import com.innocence.server.modules.plan.dto.response.WeeklyPlanTemplateResponse;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.sync.domain.SyncImportOperationRecord;
import com.innocence.server.modules.sync.dto.request.SyncImportOperationRequest;
import com.innocence.server.modules.sync.dto.request.SyncImportPreviewRequest;
import com.innocence.server.modules.sync.dto.request.SyncImportRequest;
import com.innocence.server.modules.sync.dto.response.SyncImportItemResponse;
import com.innocence.server.modules.sync.dto.response.SyncImportPreviewResponse;
import com.innocence.server.modules.sync.dto.response.SyncImportResponse;
import com.innocence.server.modules.sync.mapper.SyncImportMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

@Service
public class SyncImportService {

    private static final String ACCEPTED = "accepted";
    private static final String REJECTED = "rejected";
    private static final String CONFLICT = "conflict";

    private final AccountService accountService;
    private final StudyPlanService studyPlanService;
    private final StudyPlanMapper studyPlanMapper;
    private final MemoService memoService;
    private final FocusSessionService focusSessionService;
    private final CheckInService checkInService;
    private final SyncImportMapper syncImportMapper;
    private final ObjectMapper objectMapper;
    private final TransactionTemplate transactionTemplate;

    public SyncImportService(
            AccountService accountService,
            StudyPlanService studyPlanService,
            StudyPlanMapper studyPlanMapper,
            MemoService memoService,
            FocusSessionService focusSessionService,
            CheckInService checkInService,
            SyncImportMapper syncImportMapper,
            ObjectMapper objectMapper,
            PlatformTransactionManager transactionManager
    ) {
        this.accountService = accountService;
        this.studyPlanService = studyPlanService;
        this.studyPlanMapper = studyPlanMapper;
        this.memoService = memoService;
        this.focusSessionService = focusSessionService;
        this.checkInService = checkInService;
        this.syncImportMapper = syncImportMapper;
        this.objectMapper = objectMapper;
        this.transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public SyncImportPreviewResponse preview(Long userId, SyncImportPreviewRequest request) {
        UserProfileResponse target = accountService.getMyProfile(userId);
        List<String> conflicts = new ArrayList<>();
        for (LocalDate planDate : new LinkedHashSet<>(request.dailyPlanDates())) {
            if (planDate != null && studyPlanMapper.findDailyPlanByUserIdAndDate(userId, planDate) != null) {
                conflicts.add(planDate.toString());
            }
        }
        return new SyncImportPreviewResponse(
                target.getUserId(),
                target.getUserNo(),
                target.getNickname(),
                request.pendingOperationCount(),
                conflicts.size(),
                List.copyOf(conflicts)
        );
    }

    public SyncImportResponse importData(Long userId, SyncImportRequest request) {
        UserProfileResponse target = accountService.getMyProfile(userId);
        if (!Objects.equals(target.getUserNo(), request.targetUserNo())) {
            throw new BusinessException(
                    ErrorCode.FORBIDDEN,
                    "The confirmed target account does not match the signed-in account."
            );
        }
        String strategy = normalizeConflictStrategy(request.conflictStrategy());
        List<SyncImportOperationRequest> operations = new ArrayList<>(request.operations());
        operations.sort(Comparator
                .comparingInt((SyncImportOperationRequest operation) -> dependencyOrder(operation.aggregateType()))
                .thenComparing(SyncImportOperationRequest::createdAt)
                .thenComparing(SyncImportOperationRequest::operationId));

        List<SyncImportItemResponse> items = new ArrayList<>();
        for (SyncImportOperationRequest operation : operations) {
            items.add(importOne(userId, request.localProfileId(), strategy, operation));
        }
        int acceptedCount = (int) items.stream().filter(item -> ACCEPTED.equals(item.status())).count();
        int rejectedCount = (int) items.stream().filter(item -> REJECTED.equals(item.status())).count();
        int conflictCount = (int) items.stream().filter(item -> CONFLICT.equals(item.status())).count();
        return new SyncImportResponse(acceptedCount, rejectedCount, conflictCount, List.copyOf(items));
    }

    private SyncImportItemResponse importOne(
            Long userId,
            String localProfileId,
            String strategy,
            SyncImportOperationRequest operation
    ) {
        SyncImportOperationRecord existing = syncImportMapper.findByUserIdAndOperationId(
                userId,
                operation.operationId()
        );
        if (existing != null && ACCEPTED.equals(existing.getStatus())) {
            return toResponse(existing);
        }
        if (!Objects.equals(operation.operationId(), operation.idempotencyKey())) {
            return recordFailure(userId, localProfileId, operation, REJECTED,
                    "Operation id and idempotency key must match.");
        }

        try {
            return Objects.requireNonNull(transactionTemplate.execute(status -> {
                SyncImportOperationRecord accepted = syncImportMapper.findByUserIdAndOperationId(
                        userId,
                        operation.operationId()
                );
                if (accepted != null && ACCEPTED.equals(accepted.getStatus())) {
                    return toResponse(accepted);
                }
                String serverAggregateId = applyOperation(
                        userId,
                        localProfileId,
                        strategy,
                        operation
                );
                SyncImportOperationRecord record = buildRecord(
                        userId,
                        localProfileId,
                        operation,
                        ACCEPTED,
                        "Imported.",
                        serverAggregateId
                );
                syncImportMapper.upsertOperation(record);
                return toResponse(record);
            }));
        } catch (SyncConflictException exception) {
            return recordFailure(userId, localProfileId, operation, CONFLICT, exception.getMessage());
        } catch (BusinessException | IllegalArgumentException exception) {
            return recordFailure(userId, localProfileId, operation, REJECTED, exception.getMessage());
        } catch (RuntimeException exception) {
            return recordFailure(
                    userId,
                    localProfileId,
                    operation,
                    REJECTED,
                    "The operation could not be imported."
            );
        }
    }

    private SyncImportItemResponse recordFailure(
            Long userId,
            String localProfileId,
            SyncImportOperationRequest operation,
            String status,
            String message
    ) {
        return Objects.requireNonNull(transactionTemplate.execute(transactionStatus -> {
            SyncImportOperationRecord record = buildRecord(
                    userId,
                    localProfileId,
                    operation,
                    status,
                    message,
                    null
            );
            syncImportMapper.upsertOperation(record);
            return toResponse(record);
        }));
    }

    private String applyOperation(
            Long userId,
            String localProfileId,
            String strategy,
            SyncImportOperationRequest operation
    ) {
        return switch (operation.aggregateType()) {
            case "day_template" -> applyDayTemplate(userId, localProfileId, strategy, operation);
            case "daily_plan" -> applyDailyPlan(userId, localProfileId, strategy, operation);
            case "annual_segment" -> applyAnnualSegment(userId, localProfileId, operation);
            case "focus_session" -> applyFocusSession(userId, localProfileId, operation);
            case "memo" -> applyMemo(userId, localProfileId, operation);
            case "checkin_intent" -> applyCheckInIntent(userId, operation);
            default -> throw new IllegalArgumentException("Unsupported offline aggregate type.");
        };
    }

    private String applyDayTemplate(
            Long userId,
            String localProfileId,
            String strategy,
            SyncImportOperationRequest operation
    ) {
        SaveWeeklyTemplateRequest request = convert(operation.payload(), SaveWeeklyTemplateRequest.class);
        String existingBinding = findBinding(userId, localProfileId, operation);
        WeeklyPlanTemplate cloudTemplate = studyPlanMapper.findWeeklyTemplateByUserIdAndName(
                userId,
                request.getTemplateName() == null ? "" : request.getTemplateName().trim()
        );
        if (existingBinding == null && cloudTemplate != null && "keep_server".equals(strategy)) {
            throw new SyncConflictException("A day template with the same name already exists online.");
        }
        WeeklyPlanTemplateResponse saved = studyPlanService.saveDayTemplate(userId, request);
        return String.valueOf(saved.getId());
    }

    private String applyDailyPlan(
            Long userId,
            String localProfileId,
            String strategy,
            SyncImportOperationRequest operation
    ) {
        SaveTodayPlanRequest request = convert(operation.payload(), SaveTodayPlanRequest.class);
        LocalDate planDate = request.getPlanDate();
        DailyPlan existing = studyPlanMapper.findDailyPlanByUserIdAndDate(userId, planDate);
        if (existing != null
                && findBinding(userId, localProfileId, operation) == null
                && "keep_server".equals(strategy)) {
            throw new SyncConflictException("An online plan already exists for " + planDate + ".");
        }
        studyPlanService.saveTodayPlan(userId, request);
        return planDate.toString();
    }

    private String applyAnnualSegment(
            Long userId,
            String localProfileId,
            SyncImportOperationRequest operation
    ) {
        if ("delete".equals(operation.operationType())) {
            Long serverId = requireBoundLong(userId, localProfileId, operation);
            studyPlanService.deleteAnnualSegment(userId, serverId);
            return String.valueOf(serverId);
        }
        SaveAnnualPlanSegmentRequest request = convert(operation.payload(), SaveAnnualPlanSegmentRequest.class);
        Long serverId = boundLong(userId, localProfileId, operation);
        studyPlanService.saveAnnualSegment(userId, serverId, request);
        AnnualPlanSegment saved = studyPlanMapper.findAnnualSegmentByClientEntityIdAndUserId(
                request.getClientEntityId(),
                userId
        );
        if (saved == null) {
            throw new IllegalStateException("Imported annual segment was not found.");
        }
        return String.valueOf(saved.getId());
    }

    private String applyMemo(
            Long userId,
            String localProfileId,
            SyncImportOperationRequest operation
    ) {
        Long serverId = boundLong(userId, localProfileId, operation);
        if ("delete".equals(operation.operationType())) {
            if (serverId == null) {
                return "";
            }
            memoService.deleteMemo(userId, serverId);
            return String.valueOf(serverId);
        }
        SaveMemoRequest request = convert(operation.payload(), SaveMemoRequest.class);
        MemoCardResponse saved = serverId == null
                ? memoService.createMemo(userId, request)
                : memoService.updateMemo(userId, serverId, request);
        return String.valueOf(saved.getMemoId());
    }

    private String applyFocusSession(
            Long userId,
            String localProfileId,
            SyncImportOperationRequest operation
    ) {
        if ("finish".equals(operation.operationType())) {
            Long serverId = requireBoundLong(userId, localProfileId, operation);
            focusSessionService.finishImportedSession(
                    userId,
                    serverId,
                    parseDateTime(asText(operation.payload().get("actualEndTime"))),
                    operation.payload().containsKey("durationSeconds")
                            ? asInt(operation.payload().get("durationSeconds"))
                            : null
            );
            return String.valueOf(serverId);
        }
        if (!"create".equals(operation.operationType())) {
            throw new IllegalArgumentException("Unsupported focus operation.");
        }
        LocalDateTime startTime = parseDateTime(operation.createdAt());
        LocalDateTime endTime = parseDateTime(asText(operation.payload().get("endTime")));
        boolean bindPomodoro = Boolean.TRUE.equals(operation.payload().get("bindPomodoro"));
        Long serverId = focusSessionService.importOfflineSession(
                userId,
                startTime,
                endTime,
                asText(operation.payload().get("taskName")),
                bindPomodoro,
                asInt(operation.payload().get("pomodoroStudyMinutes")),
                asInt(operation.payload().get("pomodoroBreakMinutes"))
        );
        return String.valueOf(serverId);
    }

    private String applyCheckInIntent(Long userId, SyncImportOperationRequest operation) {
        String planDate = asText(operation.payload().get("planDate"));
        checkInService.importCheckInIntent(userId, LocalDate.parse(planDate));
        return planDate;
    }

    private String findBinding(Long userId, String localProfileId, SyncImportOperationRequest operation) {
        return syncImportMapper.findServerAggregateId(
                userId,
                localProfileId,
                operation.aggregateType(),
                operation.aggregateId()
        );
    }

    private Long boundLong(Long userId, String localProfileId, SyncImportOperationRequest operation) {
        String binding = findBinding(userId, localProfileId, operation);
        return binding == null || binding.isBlank() ? null : Long.valueOf(binding);
    }

    private Long requireBoundLong(Long userId, String localProfileId, SyncImportOperationRequest operation) {
        Long binding = boundLong(userId, localProfileId, operation);
        if (binding == null) {
            throw new IllegalArgumentException("The server binding for this offline item is missing.");
        }
        return binding;
    }

    private <T> T convert(Map<String, Object> payload, Class<T> targetType) {
        return objectMapper.convertValue(payload, targetType);
    }

    private LocalDateTime parseDateTime(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Offline operation time is required.");
        }
        try {
            if (value.endsWith("Z")) {
                return LocalDateTime.ofInstant(Instant.parse(value), ZoneId.systemDefault());
            }
            if (value.matches(".*[+-]\\d\\d:\\d\\d$")) {
                return OffsetDateTime.parse(value).atZoneSameInstant(ZoneId.systemDefault()).toLocalDateTime();
            }
            return LocalDateTime.parse(value);
        } catch (DateTimeParseException exception) {
            throw new IllegalArgumentException("Offline operation time is invalid.");
        }
    }

    private int asInt(Object value) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        try {
            return Integer.parseInt(asText(value));
        } catch (NumberFormatException exception) {
            return 0;
        }
    }

    private String asText(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String normalizeConflictStrategy(String value) {
        String strategy = value == null ? "keep_server" : value.trim().toLowerCase(Locale.ROOT);
        if (!strategy.equals("keep_server") && !strategy.equals("overwrite")) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Conflict strategy must be keep_server or overwrite.");
        }
        return strategy;
    }

    private int dependencyOrder(String aggregateType) {
        return switch (aggregateType) {
            case "day_template" -> 1;
            case "daily_plan" -> 2;
            case "annual_segment" -> 3;
            case "focus_session" -> 4;
            case "memo" -> 5;
            case "checkin_intent" -> 6;
            default -> 99;
        };
    }

    private SyncImportOperationRecord buildRecord(
            Long userId,
            String localProfileId,
            SyncImportOperationRequest operation,
            String status,
            String message,
            String serverAggregateId
    ) {
        SyncImportOperationRecord record = new SyncImportOperationRecord();
        record.setUserId(userId);
        record.setLocalProfileId(localProfileId);
        record.setOperationId(operation.operationId());
        record.setAggregateType(operation.aggregateType());
        record.setAggregateId(operation.aggregateId());
        record.setOperationType(operation.operationType());
        record.setStatus(status);
        record.setMessage(safeMessage(message));
        record.setServerAggregateId(serverAggregateId);
        return record;
    }

    private SyncImportItemResponse toResponse(SyncImportOperationRecord record) {
        return new SyncImportItemResponse(
                record.getOperationId(),
                record.getAggregateType(),
                record.getAggregateId(),
                record.getStatus(),
                record.getMessage(),
                record.getServerAggregateId()
        );
    }

    private String safeMessage(String value) {
        String message = value == null || value.isBlank() ? "The operation could not be imported." : value.trim();
        return message.length() <= 255 ? message : message.substring(0, 255);
    }

    private static final class SyncConflictException extends RuntimeException {
        private SyncConflictException(String message) {
            super(message);
        }
    }
}
