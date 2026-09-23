package com.innocence.server.modules.plan.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.notification.service.NotificationService;
import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.DailyPlanItem;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplate;
import com.innocence.server.modules.plan.domain.WeeklyPlanTemplateItem;
import com.innocence.server.modules.plan.domain.AnnualPlanSegment;
import com.innocence.server.modules.plan.domain.AnnualPlanSubtask;
import com.innocence.server.modules.plan.dto.request.AnnualPlanSubtaskRequest;
import com.innocence.server.modules.plan.dto.request.ApplyDayTemplateBatchRequest;
import com.innocence.server.modules.plan.dto.request.SaveAnnualPlanSegmentRequest;
import com.innocence.server.modules.plan.dto.request.ApplyWeeklyTemplateRequest;
import com.innocence.server.modules.plan.dto.request.SaveTodayPlanRequest;
import com.innocence.server.modules.plan.dto.request.TodayPlanItemRequest;
import com.innocence.server.modules.plan.dto.request.SaveWeeklyTemplateRequest;
import com.innocence.server.modules.plan.dto.response.WeekPlanDayResponse;
import com.innocence.server.modules.plan.dto.response.WeekPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.TodayPlanItemResponse;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.dto.response.WeeklyPlanTemplateResponse;
import com.innocence.server.modules.plan.dto.response.MonthPlanDayResponse;
import com.innocence.server.modules.plan.dto.response.MonthPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.AnnualMonthSummaryResponse;
import com.innocence.server.modules.plan.dto.response.AnnualPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.AnnualPlanSegmentResponse;
import com.innocence.server.modules.plan.dto.response.AnnualPlanSubtaskResponse;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.LinkedHashSet;
import java.util.UUID;

@Service
public class StudyPlanService {

    private final StudyPlanMapper studyPlanMapper;
    private final NotificationService notificationService;

    public StudyPlanService(
            StudyPlanMapper studyPlanMapper,
            NotificationService notificationService
    ) {
        this.studyPlanMapper = studyPlanMapper;
        this.notificationService = notificationService;
    }

    @Transactional(readOnly = true)
    public TodayPlanResponse getTodayPlan(Long userId, LocalDate planDate) {
        LocalDate normalizedPlanDate = normalizePlanDate(planDate);
        DailyPlan plan = studyPlanMapper.findDailyPlanByUserIdAndDate(userId, normalizedPlanDate);
        if (plan == null) {
            return emptyPlan(normalizedPlanDate);
        }
        List<DailyPlanItem> items = studyPlanMapper.findDailyPlanItemsByPlanId(plan.getId());
        return buildPlanResponse(plan, items);
    }

    @Transactional(readOnly = true)
    public WeekPlanOverviewResponse getWeekPlanOverview(Long userId, LocalDate anchorDate) {
        LocalDate normalizedAnchorDate = normalizePlanDate(anchorDate);
        LocalDate weekStart = startOfWeek(normalizedAnchorDate);
        LocalDate weekEnd = weekStart.plusDays(6);

        List<DailyPlan> plans = studyPlanMapper.findDailyPlansByUserIdAndDateRange(userId, weekStart, weekEnd);
        Map<Long, List<DailyPlanItem>> itemsByPlanId = new HashMap<>();
        if (!plans.isEmpty()) {
            List<Long> planIds = plans.stream()
                    .map(DailyPlan::getId)
                    .toList();
            List<DailyPlanItem> items = studyPlanMapper.findDailyPlanItemsByPlanIds(planIds);
            for (DailyPlanItem item : items) {
                itemsByPlanId.computeIfAbsent(item.getPlanId(), key -> new ArrayList<>()).add(item);
            }
        }

        Map<LocalDate, DailyPlan> planByDate = new HashMap<>();
        for (DailyPlan plan : plans) {
            planByDate.put(plan.getPlanDate(), plan);
        }

        List<WeekPlanDayResponse> days = new ArrayList<>();
        LocalDate today = LocalDate.now();
        for (int offset = 0; offset < 7; offset++) {
            LocalDate currentDate = weekStart.plusDays(offset);
            DailyPlan plan = planByDate.get(currentDate);

            WeekPlanDayResponse dayResponse = new WeekPlanDayResponse();
            dayResponse.setPlanDate(currentDate.toString());
            dayResponse.setWeekdayLabel(currentDate.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH));
            dayResponse.setToday(currentDate.equals(today));

            if (plan == null) {
                dayResponse.setHasPlan(false);
                dayResponse.setPlanName("No plan");
                dayResponse.setCompletedCount(0);
                dayResponse.setTotalCount(0);
                dayResponse.setTotalPlannedMinutes(0);
                dayResponse.setCompletedPlannedMinutes(0);
            } else {
                TodayPlanResponse planResponse = buildPlanResponse(
                        plan,
                        itemsByPlanId.getOrDefault(plan.getId(), List.of())
                );
                dayResponse.setHasPlan(true);
                dayResponse.setPlanName(planResponse.getPlanName());
                dayResponse.setCompletedCount(planResponse.getCompletedCount());
                dayResponse.setTotalCount(planResponse.getTotalCount());
                dayResponse.setTotalPlannedMinutes(planResponse.getTotalPlannedMinutes());
                dayResponse.setCompletedPlannedMinutes(planResponse.getCompletedPlannedMinutes());
            }

            days.add(dayResponse);
        }

        WeekPlanOverviewResponse response = new WeekPlanOverviewResponse();
        response.setWeekStartDate(weekStart.toString());
        response.setWeekEndDate(weekEnd.toString());
        response.setDays(days);
        return response;
    }

    @Transactional(readOnly = true)
    public MonthPlanOverviewResponse getMonthPlanOverview(Long userId, YearMonth month) {
        YearMonth normalizedMonth = month == null ? YearMonth.now() : month;
        LocalDate startDate = normalizedMonth.atDay(1);
        LocalDate endDate = normalizedMonth.atEndOfMonth();
        List<DailyPlan> plans = studyPlanMapper.findDailyPlansByUserIdAndDateRange(
                userId,
                startDate,
                endDate
        );
        Map<LocalDate, DailyPlan> planByDate = new HashMap<>();
        Map<Long, List<DailyPlanItem>> itemsByPlanId = loadItemsByPlanId(plans);
        for (DailyPlan plan : plans) {
            planByDate.put(plan.getPlanDate(), plan);
        }

        List<MonthPlanDayResponse> days = new ArrayList<>();
        for (int day = 1; day <= normalizedMonth.lengthOfMonth(); day++) {
            LocalDate date = normalizedMonth.atDay(day);
            DailyPlan plan = planByDate.get(date);
            if (plan == null) {
                days.add(new MonthPlanDayResponse(
                        date.toString(), false, "", 0, 0, 0, false
                ));
                continue;
            }
            TodayPlanResponse summary = buildPlanResponse(
                    plan,
                    itemsByPlanId.getOrDefault(plan.getId(), List.of())
            );
            days.add(new MonthPlanDayResponse(
                    date.toString(),
                    summary.getTotalCount() > 0,
                    summary.getPlanName(),
                    summary.getCompletedCount(),
                    summary.getTotalCount(),
                    summary.getTotalPlannedMinutes(),
                    false
            ));
        }
        return new MonthPlanOverviewResponse(normalizedMonth.toString(), days);
    }

    @Transactional(readOnly = true)
    public AnnualPlanOverviewResponse getAnnualPlanOverview(Long userId, int year) {
        LocalDate startDate = LocalDate.of(year, 1, 1);
        LocalDate endDate = LocalDate.of(year, 12, 31);
        List<DailyPlan> plans = studyPlanMapper.findDailyPlansByUserIdAndDateRange(
                userId,
                startDate,
                endDate
        );
        Map<Long, List<DailyPlanItem>> itemsByPlanId = loadItemsByPlanId(plans);
        List<AnnualMonthSummaryResponse> months = new ArrayList<>();
        for (int month = 1; month <= 12; month++) {
            int plannedDayCount = 0;
            int completedTaskCount = 0;
            int totalTaskCount = 0;
            int totalPlannedMinutes = 0;
            for (DailyPlan plan : plans) {
                if (plan.getPlanDate().getMonthValue() != month) {
                    continue;
                }
                TodayPlanResponse summary = buildPlanResponse(
                        plan,
                        itemsByPlanId.getOrDefault(plan.getId(), List.of())
                );
                if (summary.getTotalCount() > 0) {
                    plannedDayCount++;
                }
                completedTaskCount += summary.getCompletedCount();
                totalTaskCount += summary.getTotalCount();
                totalPlannedMinutes += summary.getTotalPlannedMinutes();
            }
            months.add(new AnnualMonthSummaryResponse(
                    month,
                    plannedDayCount,
                    completedTaskCount,
                    totalTaskCount,
                    totalPlannedMinutes
            ));
        }
        List<AnnualPlanSegmentResponse> segments = studyPlanMapper
                .findAnnualSegmentsByUserIdAndYear(userId, year)
                .stream()
                .map(this::buildAnnualSegmentResponse)
                .toList();
        return new AnnualPlanOverviewResponse(year, months, segments);
    }

    @Transactional
    public TodayPlanResponse saveTodayPlan(Long userId, SaveTodayPlanRequest request) {
        LocalDate normalizedPlanDate = normalizePlanDate(request.getPlanDate());
        String planName = normalizePlanName(request.getPlanName());
        List<TodayPlanItemRequest> requestItems = request.getItems() == null ? new ArrayList<>() : request.getItems();
        validateShortPlanItems(requestItems);

        DailyPlan existingPlan = studyPlanMapper.findDailyPlanByUserIdAndDate(userId, normalizedPlanDate);
        boolean shouldClearPlan = requestItems.isEmpty() && (request.getPlanName() == null || request.getPlanName().isBlank());

        if (shouldClearPlan) {
            if (existingPlan != null) {
                studyPlanMapper.deleteDailyPlanItemsByPlanId(existingPlan.getId());
                studyPlanMapper.deleteDailyPlanById(existingPlan.getId());
            }
            return emptyPlan(normalizedPlanDate);
        }

        DailyPlan targetPlan = existingPlan;
        if (targetPlan == null) {
            targetPlan = new DailyPlan();
            targetPlan.setUserId(userId);
            targetPlan.setPlanDate(normalizedPlanDate);
            targetPlan.setPlanName(planName);
            targetPlan.setPlanType(resolvePlanType(requestItems));
            studyPlanMapper.insertDailyPlan(targetPlan);
        } else {
            targetPlan.setPlanName(planName);
            targetPlan.setPlanType(resolvePlanType(requestItems));
            studyPlanMapper.updateDailyPlan(targetPlan);
            studyPlanMapper.deleteDailyPlanItemsByPlanId(targetPlan.getId());
        }

        int sortOrder = 0;
        for (TodayPlanItemRequest requestItem : requestItems) {
            DailyPlanItem item = new DailyPlanItem();
            item.setPlanId(targetPlan.getId());
            item.setUserId(userId);
            item.setTitle(requestItem.getTitle().trim());
            item.setStatus(Boolean.TRUE.equals(requestItem.getCompleted()) ? 1 : 0);
            item.setPlannedMinutes(resolvePlannedMinutes(requestItem));
            item.setActualMinutes(defaultNumber(requestItem.getActualMinutes()));
            item.setStartSlot(requestItem.getStartSlot());
            item.setEndSlot(requestItem.getEndSlot());
            item.setSortOrder(sortOrder++);
            studyPlanMapper.insertDailyPlanItem(item);
        }

        TodayPlanResponse response = getTodayPlan(userId, normalizedPlanDate);
        notificationService.createPlanCompletionNotifications(
                userId,
                response.getPlanDate(),
                response.getPlanName(),
                response.getCompletedCount(),
                response.getTotalCount()
        );
        return response;
    }

    @Transactional(readOnly = true)
    public List<WeeklyPlanTemplateResponse> getWeeklyTemplates(Long userId) {
        List<WeeklyPlanTemplate> templates = studyPlanMapper.findWeeklyTemplatesByUserId(userId);
        List<WeeklyPlanTemplateResponse> responses = new ArrayList<>();

        for (WeeklyPlanTemplate template : templates) {
            List<WeeklyPlanTemplateItem> items = studyPlanMapper.findWeeklyTemplateItemsByTemplateId(template.getId());
            responses.add(buildWeeklyTemplateResponse(template, items));
        }

        return responses;
    }

    @Transactional(readOnly = true)
    public List<WeeklyPlanTemplateResponse> getDayTemplates(Long userId) {
        return getWeeklyTemplates(userId);
    }

    @Transactional
    public WeeklyPlanTemplateResponse saveWeeklyTemplate(Long userId, SaveWeeklyTemplateRequest request) {
        List<TodayPlanItemRequest> requestItems = request.getItems() == null ? new ArrayList<>() : request.getItems();
        if (requestItems.isEmpty()) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Weekly template must contain at least one task.");
        }
        validateShortPlanItems(requestItems);

        String templateName = normalizeTemplateName(request.getTemplateName());
        String sourcePlanName = normalizePlanName(request.getSourcePlanName());
        WeeklyPlanTemplate existingTemplate =
                studyPlanMapper.findWeeklyTemplateByUserIdAndName(userId, templateName);

        WeeklyPlanTemplate targetTemplate = existingTemplate;
        if (targetTemplate == null) {
            targetTemplate = new WeeklyPlanTemplate();
            targetTemplate.setUserId(userId);
            targetTemplate.setTemplateName(templateName);
            targetTemplate.setSourcePlanName(sourcePlanName);
            studyPlanMapper.insertWeeklyPlanTemplate(targetTemplate);
        } else {
            targetTemplate.setSourcePlanName(sourcePlanName);
            studyPlanMapper.updateWeeklyPlanTemplate(targetTemplate);
            studyPlanMapper.deleteWeeklyPlanTemplateItemsByTemplateId(targetTemplate.getId());
        }

        int sortOrder = 0;
        for (TodayPlanItemRequest requestItem : requestItems) {
            WeeklyPlanTemplateItem item = new WeeklyPlanTemplateItem();
            item.setTemplateId(targetTemplate.getId());
            item.setUserId(userId);
            item.setTitle(requestItem.getTitle().trim());
            item.setPlannedMinutes(resolvePlannedMinutes(requestItem));
            item.setStartSlot(requestItem.getStartSlot());
            item.setEndSlot(requestItem.getEndSlot());
            item.setSortOrder(sortOrder++);
            studyPlanMapper.insertWeeklyPlanTemplateItem(item);
        }

        List<WeeklyPlanTemplateItem> savedItems =
                studyPlanMapper.findWeeklyTemplateItemsByTemplateId(targetTemplate.getId());
        return buildWeeklyTemplateResponse(targetTemplate, savedItems);
    }

    @Transactional
    public WeeklyPlanTemplateResponse saveDayTemplate(Long userId, SaveWeeklyTemplateRequest request) {
        return saveWeeklyTemplate(userId, request);
    }

    @Transactional
    public List<TodayPlanResponse> applyDayTemplateBatch(
            Long userId,
            Long templateId,
            ApplyDayTemplateBatchRequest request
    ) {
        if (request == null || request.getPlanDates().isEmpty()) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "At least one plan date is required.");
        }
        String strategy = request.getStrategy() == null
                ? "skip"
                : request.getStrategy().trim().toLowerCase(Locale.ROOT);
        if (!strategy.equals("skip") && !strategy.equals("overwrite")) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Strategy must be skip or overwrite.");
        }
        WeeklyPlanTemplate template = studyPlanMapper.findWeeklyTemplateByIdAndUserId(templateId, userId);
        if (template == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Day template not found.");
        }

        List<TodayPlanResponse> results = new ArrayList<>();
        for (LocalDate planDate : new LinkedHashSet<>(request.getPlanDates())) {
            DailyPlan existing = studyPlanMapper.findDailyPlanByUserIdAndDate(userId, planDate);
            if (existing != null && strategy.equals("skip")) {
                results.add(getTodayPlan(userId, planDate));
                continue;
            }
            ApplyWeeklyTemplateRequest singleRequest = new ApplyWeeklyTemplateRequest();
            singleRequest.setPlanDate(planDate);
            results.add(applyWeeklyTemplate(userId, templateId, singleRequest));
        }
        return results;
    }

    @Transactional
    public AnnualPlanOverviewResponse saveAnnualSegment(
            Long userId,
            Long segmentId,
            SaveAnnualPlanSegmentRequest request
    ) {
        validateAnnualSegment(request);
        AnnualPlanSegment segment = segmentId == null
                ? null
                : studyPlanMapper.findAnnualSegmentByIdAndUserId(segmentId, userId);
        if (segmentId != null && segment == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Annual plan segment not found.");
        }
        if (segment == null && request.getClientEntityId() != null && !request.getClientEntityId().isBlank()) {
            segment = studyPlanMapper.findAnnualSegmentByClientEntityIdAndUserId(
                    request.getClientEntityId().trim(),
                    userId
            );
        }
        boolean creating = segment == null;
        if (creating) {
            segment = new AnnualPlanSegment();
            segment.setUserId(userId);
            segment.setClientEntityId(
                    request.getClientEntityId() == null || request.getClientEntityId().isBlank()
                            ? UUID.randomUUID().toString()
                            : request.getClientEntityId().trim()
            );
            segment.setRevision(1);
        } else {
            int expectedRevision = request.getRevision() == null ? 0 : request.getRevision();
            int currentRevision = segment.getRevision() == null ? 0 : segment.getRevision();
            if (expectedRevision > 0 && expectedRevision != currentRevision) {
                throw new BusinessException(ErrorCode.BAD_REQUEST, "Annual plan segment revision conflict.");
            }
            segment.setRevision(currentRevision + 1);
        }
        segment.setPlanYear(request.getYear());
        segment.setTitle(request.getTitle().trim());
        segment.setStartMonth(request.getStartMonth());
        segment.setEndMonth(request.getEndMonth());
        segment.setColorKey(normalizeColorKey(request.getColorKey()));
        segment.setSortOrder(request.getSortOrder() == null ? 0 : request.getSortOrder());
        segment.setNote(request.getNote() == null ? "" : request.getNote().trim());
        segment.setProgressPercent(request.getProgressPercent() == null
                ? (creating || segment.getProgressPercent() == null ? 0 : segment.getProgressPercent())
                : request.getProgressPercent());
        if (creating) {
            studyPlanMapper.insertAnnualPlanSegment(segment);
        } else {
            studyPlanMapper.updateAnnualPlanSegment(segment);
        }
        studyPlanMapper.deleteAnnualPlanSubtasksBySegmentIdAndUserId(
                segment.getId(),
                userId
        );
        int subtaskOrder = 0;
        for (AnnualPlanSubtaskRequest requestSubtask : request.getSubtasks()) {
            AnnualPlanSubtask subtask = new AnnualPlanSubtask();
            subtask.setSegmentId(segment.getId());
            subtask.setUserId(userId);
            subtask.setTitle(requestSubtask.getTitle().trim());
            subtask.setDetail(
                    requestSubtask.getDetail() == null
                            ? ""
                            : requestSubtask.getDetail().trim()
            );
            subtask.setStatus(Boolean.TRUE.equals(requestSubtask.getCompleted()) ? 1 : 0);
            subtask.setSortOrder(
                    requestSubtask.getSortOrder() == null
                            ? subtaskOrder
                            : requestSubtask.getSortOrder()
            );
            studyPlanMapper.insertAnnualPlanSubtask(subtask);
            subtaskOrder++;
        }
        return getAnnualPlanOverview(userId, request.getYear());
    }

    @Transactional
    public void deleteAnnualSegment(Long userId, Long segmentId) {
        AnnualPlanSegment segment = studyPlanMapper.findAnnualSegmentByIdAndUserId(segmentId, userId);
        if (segment == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Annual plan segment not found.");
        }
        studyPlanMapper.deleteAnnualPlanSubtasksBySegmentIdAndUserId(segmentId, userId);
        studyPlanMapper.deleteAnnualPlanSegmentByIdAndUserId(segmentId, userId);
    }

    @Transactional
    public TodayPlanResponse applyWeeklyTemplate(Long userId, Long templateId, ApplyWeeklyTemplateRequest request) {
        WeeklyPlanTemplate template = studyPlanMapper.findWeeklyTemplateByIdAndUserId(templateId, userId);
        if (template == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Weekly template not found.");
        }

        List<WeeklyPlanTemplateItem> templateItems =
                studyPlanMapper.findWeeklyTemplateItemsByTemplateId(template.getId());

        SaveTodayPlanRequest saveRequest = new SaveTodayPlanRequest();
        LocalDate targetDate = request == null || request.getPlanDate() == null
                ? LocalDate.now()
                : request.getPlanDate();
        saveRequest.setPlanDate(targetDate);
        saveRequest.setPlanName(template.getTemplateName());

        List<TodayPlanItemRequest> items = new ArrayList<>();
        for (WeeklyPlanTemplateItem templateItem : templateItems) {
            TodayPlanItemRequest itemRequest = new TodayPlanItemRequest();
            itemRequest.setTitle(templateItem.getTitle());
            itemRequest.setPlannedMinutes(templateItem.getPlannedMinutes());
            itemRequest.setActualMinutes(0);
            itemRequest.setCompleted(false);
            itemRequest.setStartSlot(templateItem.getStartSlot());
            itemRequest.setEndSlot(templateItem.getEndSlot());
            items.add(itemRequest);
        }
        saveRequest.setItems(items);
        return saveTodayPlan(userId, saveRequest);
    }

    @Transactional
    public void deleteWeeklyTemplate(Long userId, Long templateId) {
        WeeklyPlanTemplate template = studyPlanMapper.findWeeklyTemplateByIdAndUserId(templateId, userId);
        if (template == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "Weekly template not found.");
        }

        studyPlanMapper.deleteWeeklyPlanTemplateItemsByTemplateId(templateId);
        studyPlanMapper.deleteWeeklyPlanTemplateByIdAndUserId(templateId, userId);
    }

    private Map<Long, List<DailyPlanItem>> loadItemsByPlanId(List<DailyPlan> plans) {
        Map<Long, List<DailyPlanItem>> itemsByPlanId = new HashMap<>();
        if (plans.isEmpty()) {
            return itemsByPlanId;
        }
        List<Long> planIds = plans.stream().map(DailyPlan::getId).toList();
        for (DailyPlanItem item : studyPlanMapper.findDailyPlanItemsByPlanIds(planIds)) {
            itemsByPlanId.computeIfAbsent(item.getPlanId(), key -> new ArrayList<>()).add(item);
        }
        return itemsByPlanId;
    }

    private AnnualPlanSegmentResponse buildAnnualSegmentResponse(AnnualPlanSegment segment) {
        List<AnnualPlanSubtaskResponse> subtasks = studyPlanMapper
                .findAnnualPlanSubtasksBySegmentId(segment.getId(), segment.getUserId())
                .stream()
                .map(subtask -> new AnnualPlanSubtaskResponse(
                        String.valueOf(subtask.getId()),
                        subtask.getTitle(),
                        subtask.getDetail() == null ? "" : subtask.getDetail(),
                        subtask.getStatus() != null && subtask.getStatus() == 1,
                        subtask.getSortOrder() == null ? 0 : subtask.getSortOrder()
                ))
                .toList();
        return new AnnualPlanSegmentResponse(
                String.valueOf(segment.getId()),
                segment.getClientEntityId(),
                segment.getPlanYear() == null ? 0 : segment.getPlanYear(),
                segment.getTitle(),
                segment.getStartMonth() == null ? 1 : segment.getStartMonth(),
                segment.getEndMonth() == null ? 1 : segment.getEndMonth(),
                normalizeColorKey(segment.getColorKey()),
                segment.getSortOrder() == null ? 0 : segment.getSortOrder(),
                segment.getNote() == null ? "" : segment.getNote(),
                segment.getProgressPercent() == null ? 0 : segment.getProgressPercent(),
                segment.getRevision() == null ? 0 : segment.getRevision(),
                segment.getUpdateTime() == null ? "" : segment.getUpdateTime().toString(),
                subtasks
        );
    }

    private void validateAnnualSegment(SaveAnnualPlanSegmentRequest request) {
        if (request == null || request.getYear() == null || request.getYear() < 1
                || request.getYear() > 9999 || request.getTitle() == null
                || request.getTitle().isBlank() || request.getTitle().length() > 96) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Annual task year and title are required.");
        }
        if (request.getStartMonth() == null || request.getEndMonth() == null
                || request.getStartMonth() < 1 || request.getStartMonth() > 12
                || request.getEndMonth() < 1 || request.getEndMonth() > 12) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Start and end month must be within 1...12.");
        }
        if (request.getStartMonth() > request.getEndMonth()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Start month must not be after end month.");
        }
        if (request.getProgressPercent() != null
                && (request.getProgressPercent() < 0 || request.getProgressPercent() > 100)) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Annual task progress must be within 0...100.");
        }
        if (request.getSubtasks().size() > 100) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "An annual task supports at most 100 subtasks.");
        }
        for (AnnualPlanSubtaskRequest subtask : request.getSubtasks()) {
            if (subtask == null || subtask.getTitle() == null
                    || subtask.getTitle().isBlank() || subtask.getTitle().length() > 128
                    || (subtask.getDetail() != null && subtask.getDetail().length() > 500)) {
                throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Invalid annual subtask.");
            }
        }
    }

    private String normalizeColorKey(String colorKey) {
        if (colorKey == null || colorKey.isBlank()) {
            return "accent";
        }
        String normalized = colorKey.trim().toLowerCase(Locale.ROOT);
        if (!List.of("accent", "warm", "cool", "neutral", "coral", "gold", "cyan").contains(normalized)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Unsupported annual segment color key.");
        }
        return normalized;
    }

    private TodayPlanResponse buildPlanResponse(DailyPlan plan, List<DailyPlanItem> items) {
        TodayPlanResponse response = new TodayPlanResponse();
        response.setPlanDate(plan.getPlanDate().toString());
        response.setPlanName(normalizePlanName(plan.getPlanName()));

        int completedCount = 0;
        int totalPlannedMinutes = 0;
        int completedPlannedMinutes = 0;
        List<TodayPlanItemResponse> itemResponses = new ArrayList<>();

        for (DailyPlanItem item : items) {
            TodayPlanItemResponse itemResponse = new TodayPlanItemResponse();
            itemResponse.setId(item.getId());
            itemResponse.setTitle(item.getTitle());
            itemResponse.setCompleted(item.getStatus() == null ? 0 : item.getStatus());
            itemResponse.setPlannedMinutes(defaultNumber(item.getPlannedMinutes()));
            itemResponse.setActualMinutes(defaultNumber(item.getActualMinutes()));
            itemResponse.setStartSlot(item.getStartSlot());
            itemResponse.setEndSlot(item.getEndSlot());
            itemResponse.setSortOrder(item.getSortOrder() == null ? 0 : item.getSortOrder());
            itemResponses.add(itemResponse);

            totalPlannedMinutes += itemResponse.getPlannedMinutes();
            if (itemResponse.getCompleted() == 1) {
                completedCount++;
                completedPlannedMinutes += itemResponse.getPlannedMinutes();
            }
        }

        response.setCompletedCount(completedCount);
        response.setTotalCount(itemResponses.size());
        response.setTotalPlannedMinutes(totalPlannedMinutes);
        response.setCompletedPlannedMinutes(completedPlannedMinutes);
        response.setItems(itemResponses);
        return response;
    }

    private WeeklyPlanTemplateResponse buildWeeklyTemplateResponse(
            WeeklyPlanTemplate template,
            List<WeeklyPlanTemplateItem> items
    ) {
        WeeklyPlanTemplateResponse response = new WeeklyPlanTemplateResponse();
        response.setId(template.getId());
        response.setTemplateName(template.getTemplateName());
        response.setSourcePlanName(normalizePlanName(template.getSourcePlanName()));

        int totalPlannedMinutes = 0;
        List<TodayPlanItemResponse> itemResponses = new ArrayList<>();
        for (WeeklyPlanTemplateItem item : items) {
            TodayPlanItemResponse itemResponse = new TodayPlanItemResponse();
            itemResponse.setId(item.getId());
            itemResponse.setTitle(item.getTitle());
            itemResponse.setCompleted(0);
            itemResponse.setPlannedMinutes(defaultNumber(item.getPlannedMinutes()));
            itemResponse.setActualMinutes(0);
            itemResponse.setStartSlot(item.getStartSlot());
            itemResponse.setEndSlot(item.getEndSlot());
            itemResponse.setSortOrder(item.getSortOrder() == null ? 0 : item.getSortOrder());
            itemResponses.add(itemResponse);
            totalPlannedMinutes += itemResponse.getPlannedMinutes();
        }

        response.setItemCount(itemResponses.size());
        response.setTotalPlannedMinutes(totalPlannedMinutes);
        response.setItems(itemResponses);
        return response;
    }

    private TodayPlanResponse emptyPlan(LocalDate planDate) {
        TodayPlanResponse response = new TodayPlanResponse();
        response.setPlanDate(planDate.toString());
        response.setPlanName("Today");
        response.setCompletedCount(0);
        response.setTotalCount(0);
        response.setTotalPlannedMinutes(0);
        response.setCompletedPlannedMinutes(0);
        response.setItems(new ArrayList<>());
        return response;
    }

    private LocalDate normalizePlanDate(LocalDate planDate) {
        return planDate == null ? LocalDate.now() : planDate;
    }

    private LocalDate startOfWeek(LocalDate date) {
        return date.minusDays(date.getDayOfWeek().getValue() - 1L);
    }

    private String normalizePlanName(String planName) {
        if (planName == null || planName.isBlank()) {
            return "Today";
        }
        return planName.trim();
    }

    private String normalizeTemplateName(String templateName) {
        if (templateName == null || templateName.isBlank()) {
            throw new BusinessException(ErrorCode.VALIDATION_ERROR, "Template name is required.");
        }
        return templateName.trim();
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private int resolvePlannedMinutes(TodayPlanItemRequest requestItem) {
        if (requestItem.getStartSlot() != null && requestItem.getEndSlot() != null) {
            return (requestItem.getEndSlot() - requestItem.getStartSlot()) * 30;
        }
        return defaultNumber(requestItem.getPlannedMinutes());
    }

    private String resolvePlanType(List<TodayPlanItemRequest> requestItems) {
        return requestItems.stream().anyMatch(this::hasSchedule) ? "short_schedule" : "manual";
    }

    private void validateShortPlanItems(List<TodayPlanItemRequest> requestItems) {
        List<ShortPlanRange> scheduledRanges = new ArrayList<>();

        for (TodayPlanItemRequest requestItem : requestItems) {
            boolean hasStart = requestItem.getStartSlot() != null;
            boolean hasEnd = requestItem.getEndSlot() != null;

            if (hasStart != hasEnd) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "A short-plan block must include both start and end time."
                );
            }

            if (!hasStart) {
                continue;
            }

            int startSlot = requestItem.getStartSlot();
            int endSlot = requestItem.getEndSlot();
            if (endSlot <= startSlot) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "Short-plan blocks must end after they start."
                );
            }

            scheduledRanges.add(new ShortPlanRange(startSlot, endSlot, requestItem.getTitle().trim()));
        }

        scheduledRanges.sort(Comparator.comparingInt(ShortPlanRange::startSlot));
        for (int index = 1; index < scheduledRanges.size(); index++) {
            ShortPlanRange previous = scheduledRanges.get(index - 1);
            ShortPlanRange current = scheduledRanges.get(index);
            if (current.startSlot() < previous.endSlot()) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "Short-plan time blocks cannot overlap."
                );
            }
        }
    }

    private boolean hasSchedule(TodayPlanItemRequest requestItem) {
        return requestItem.getStartSlot() != null && requestItem.getEndSlot() != null;
    }

    private record ShortPlanRange(int startSlot, int endSlot, String title) {
    }
}
