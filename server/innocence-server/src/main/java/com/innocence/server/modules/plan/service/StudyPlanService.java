package com.innocence.server.modules.plan.service;

import com.innocence.server.modules.plan.domain.DailyPlan;
import com.innocence.server.modules.plan.domain.DailyPlanItem;
import com.innocence.server.modules.plan.dto.request.SaveTodayPlanRequest;
import com.innocence.server.modules.plan.dto.request.TodayPlanItemRequest;
import com.innocence.server.modules.plan.dto.response.TodayPlanItemResponse;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class StudyPlanService {

    private final StudyPlanMapper studyPlanMapper;

    public StudyPlanService(StudyPlanMapper studyPlanMapper) {
        this.studyPlanMapper = studyPlanMapper;
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

    @Transactional
    public TodayPlanResponse saveTodayPlan(Long userId, SaveTodayPlanRequest request) {
        LocalDate normalizedPlanDate = normalizePlanDate(request.getPlanDate());
        String planName = normalizePlanName(request.getPlanName());
        List<TodayPlanItemRequest> requestItems = request.getItems() == null ? new ArrayList<>() : request.getItems();

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
            targetPlan.setPlanType("manual");
            studyPlanMapper.insertDailyPlan(targetPlan);
        } else {
            targetPlan.setPlanName(planName);
            targetPlan.setPlanType("manual");
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
            item.setPlannedMinutes(defaultNumber(requestItem.getPlannedMinutes()));
            item.setActualMinutes(defaultNumber(requestItem.getActualMinutes()));
            item.setSortOrder(sortOrder++);
            studyPlanMapper.insertDailyPlanItem(item);
        }

        return getTodayPlan(userId, normalizedPlanDate);
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

    private String normalizePlanName(String planName) {
        if (planName == null || planName.isBlank()) {
            return "Today";
        }
        return planName.trim();
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }
}
