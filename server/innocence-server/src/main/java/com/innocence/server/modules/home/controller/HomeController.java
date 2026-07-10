package com.innocence.server.modules.home.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.checkin.dto.response.CheckInStatusResponse;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.focus.dto.response.FocusSessionResponse;
import com.innocence.server.modules.focus.service.FocusSessionService;
import com.innocence.server.modules.memo.dto.response.MemoSummaryResponse;
import com.innocence.server.modules.memo.service.MemoService;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.stats.dto.response.StatsOverviewResponse;
import com.innocence.server.modules.stats.service.StatsService;
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
    private final FocusSessionService focusSessionService;
    private final CheckInService checkInService;
    private final StatsService statsService;
    private final MemoService memoService;

    public HomeController(
            StudyPlanService studyPlanService,
            FocusSessionService focusSessionService,
            CheckInService checkInService,
            StatsService statsService,
            MemoService memoService
    ) {
        this.studyPlanService = studyPlanService;
        this.focusSessionService = focusSessionService;
        this.checkInService = checkInService;
        this.statsService = statsService;
        this.memoService = memoService;
    }

    @GetMapping("/overview")
    public ApiResponse<Map<String, Object>> overview() {
        FocusSessionResponse currentStudyState = focusSessionService.getCurrentSession(currentUserId());
        TodayPlanResponse todayPlan = studyPlanService.getTodayPlan(currentUserId(), LocalDate.now());
        CheckInStatusResponse checkInStatus = checkInService.getTodayStatus(currentUserId());
        StatsOverviewResponse statsOverview = statsService.getOverview(currentUserId(), 7);
        MemoSummaryResponse memoSummary = memoService.getSummary(currentUserId(), 3);

        return ApiResponse.success(Map.of(
                "currentStudyState", currentStudyState,
                "todayPlan", Map.of(
                        "planName", todayPlan.getPlanName(),
                        "completedCount", todayPlan.getCompletedCount(),
                        "totalCount", todayPlan.getTotalCount(),
                        "totalPlannedMinutes", todayPlan.getTotalPlannedMinutes()
                ),
                "checkInSummary", checkInStatus,
                "trendSummary", statsOverview,
                "teammateSummary", List.of(),
                "memoSummary", memoSummary
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
