package com.innocence.server.modules.checkin.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.checkin.dto.response.CheckInStatusResponse;
import com.innocence.server.modules.checkin.dto.response.CheckInSubmitResponse;
import com.innocence.server.modules.checkin.service.CheckInService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/app/v1/check-in")
public class CheckInController {

    private final CheckInService checkInService;

    public CheckInController(CheckInService checkInService) {
        this.checkInService = checkInService;
    }

    @GetMapping("/today")
    public ApiResponse<CheckInStatusResponse> getTodayStatus() {
        return ApiResponse.success(checkInService.getTodayStatus(currentUserId()));
    }

    @PostMapping("/submit")
    public ApiResponse<CheckInSubmitResponse> submitTodayCheckIn() {
        return ApiResponse.success(checkInService.submitTodayCheckIn(currentUserId()));
    }

    @DeleteMapping("/failure")
    public ApiResponse<Boolean> deleteFailureRecord(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate date
    ) {
        return ApiResponse.success(checkInService.deleteFailureRecord(currentUserId(), date));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
