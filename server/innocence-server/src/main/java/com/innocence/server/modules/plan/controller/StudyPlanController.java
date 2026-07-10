package com.innocence.server.modules.plan.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.plan.dto.request.ApplyWeeklyTemplateRequest;
import com.innocence.server.modules.plan.dto.request.SaveTodayPlanRequest;
import com.innocence.server.modules.plan.dto.request.SaveWeeklyTemplateRequest;
import com.innocence.server.modules.plan.dto.response.WeekPlanOverviewResponse;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.innocence.server.modules.plan.dto.response.WeeklyPlanTemplateResponse;
import com.innocence.server.modules.plan.service.StudyPlanService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/app/v1/plans")
public class StudyPlanController {

    private final StudyPlanService studyPlanService;

    public StudyPlanController(StudyPlanService studyPlanService) {
        this.studyPlanService = studyPlanService;
    }

    @GetMapping("/today")
    public ApiResponse<TodayPlanResponse> getTodayPlan(
            @RequestParam(name = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate planDate
    ) {
        return ApiResponse.success(studyPlanService.getTodayPlan(currentUserId(), planDate));
    }

    @GetMapping("/week")
    public ApiResponse<WeekPlanOverviewResponse> getWeekPlanOverview(
            @RequestParam(name = "anchorDate", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate anchorDate
    ) {
        return ApiResponse.success(studyPlanService.getWeekPlanOverview(currentUserId(), anchorDate));
    }

    @PutMapping("/today")
    public ApiResponse<TodayPlanResponse> saveTodayPlan(@Valid @RequestBody SaveTodayPlanRequest request) {
        return ApiResponse.success(studyPlanService.saveTodayPlan(currentUserId(), request));
    }

    @GetMapping("/weekly-templates")
    public ApiResponse<List<WeeklyPlanTemplateResponse>> getWeeklyTemplates() {
        return ApiResponse.success(studyPlanService.getWeeklyTemplates(currentUserId()));
    }

    @PutMapping("/weekly-templates")
    public ApiResponse<WeeklyPlanTemplateResponse> saveWeeklyTemplate(
            @Valid @RequestBody SaveWeeklyTemplateRequest request
    ) {
        return ApiResponse.success(studyPlanService.saveWeeklyTemplate(currentUserId(), request));
    }

    @PostMapping("/weekly-templates/{templateId}/apply")
    public ApiResponse<TodayPlanResponse> applyWeeklyTemplate(
            @PathVariable("templateId") Long templateId,
            @RequestBody(required = false) ApplyWeeklyTemplateRequest request
    ) {
        return ApiResponse.success(
                studyPlanService.applyWeeklyTemplate(currentUserId(), templateId, request)
        );
    }

    @DeleteMapping("/weekly-templates/{templateId}")
    public ApiResponse<Boolean> deleteWeeklyTemplate(@PathVariable("templateId") Long templateId) {
        studyPlanService.deleteWeeklyTemplate(currentUserId(), templateId);
        return ApiResponse.success(Boolean.TRUE);
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
