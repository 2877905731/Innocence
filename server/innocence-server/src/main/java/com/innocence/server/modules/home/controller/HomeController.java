package com.innocence.server.modules.home.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.service.StudyPlanService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/app/v1/home")
public class HomeController {

    private final StudyPlanService studyPlanService;

    public HomeController(StudyPlanService studyPlanService) {
        this.studyPlanService = studyPlanService;
    }

    @GetMapping("/overview")
    public ApiResponse<Map<String, Object>> overview() {
        TodayPlanResponse todayPlan = studyPlanService.getTodayPlan(currentUserId(), LocalDate.now());
        return ApiResponse.success(Map.of(
                "currentStudyState", Map.of(
                        "active", false,
                        "taskName", "",
                        "remainingSeconds", 0
                ),
                "todayPlan", Map.of(
                        "planName", todayPlan.getPlanName(),
                        "completedCount", todayPlan.getCompletedCount(),
                        "totalCount", todayPlan.getTotalCount(),
                        "totalPlannedMinutes", todayPlan.getTotalPlannedMinutes()
                ),
                "checkInSummary", Map.of(
                        "consecutiveDays", 0,
                        "totalDays", 0,
                        "totalStudyDurationMinutes", 0
                ),
                "trendSummary", List.of(),
                "teammateSummary", List.of(),
                "memoSummary", List.of()
        ));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
