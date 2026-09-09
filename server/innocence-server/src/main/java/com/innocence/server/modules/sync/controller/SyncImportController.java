package com.innocence.server.modules.sync.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.sync.dto.request.SyncImportPreviewRequest;
import com.innocence.server.modules.sync.dto.request.SyncImportRequest;
import com.innocence.server.modules.sync.dto.response.SyncImportPreviewResponse;
import com.innocence.server.modules.sync.dto.response.SyncImportResponse;
import com.innocence.server.modules.sync.service.SyncImportService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/app/v1/sync")
public class SyncImportController {

    private final SyncImportService syncImportService;

    public SyncImportController(SyncImportService syncImportService) {
        this.syncImportService = syncImportService;
    }

    @PostMapping("/import-preview")
    public ApiResponse<SyncImportPreviewResponse> preview(
            @Valid @RequestBody SyncImportPreviewRequest request
    ) {
        return ApiResponse.success(syncImportService.preview(currentUserId(), request));
    }

    @PostMapping("/import")
    public ApiResponse<SyncImportResponse> importData(
            @Valid @RequestBody SyncImportRequest request
    ) {
        return ApiResponse.success(syncImportService.importData(currentUserId(), request));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "Please sign in first.");
        }
        return userId;
    }
}
