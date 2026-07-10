package com.innocence.server.modules.memo.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.memo.dto.request.SaveMemoRequest;
import com.innocence.server.modules.memo.dto.response.MemoCardResponse;
import com.innocence.server.modules.memo.dto.response.MemoSummaryResponse;
import com.innocence.server.modules.memo.service.MemoService;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/app/v1/memos")
public class MemoController {

    private final MemoService memoService;

    public MemoController(MemoService memoService) {
        this.memoService = memoService;
    }

    @GetMapping
    public ApiResponse<List<MemoCardResponse>> list(
            @RequestParam(value = "pageNo", required = false, defaultValue = "1") Integer pageNo,
            @RequestParam(value = "pageSize", required = false, defaultValue = "20") Integer pageSize
    ) {
        return ApiResponse.success(memoService.listMemos(currentUserId(), pageNo, pageSize));
    }

    @PostMapping
    public ApiResponse<MemoCardResponse> create(@RequestBody SaveMemoRequest request) {
        return ApiResponse.success(memoService.createMemo(currentUserId(), request));
    }

    @GetMapping("/{memoId}")
    public ApiResponse<MemoCardResponse> detail(@PathVariable Long memoId) {
        return ApiResponse.success(memoService.getMemo(currentUserId(), memoId));
    }

    @PutMapping("/{memoId}")
    public ApiResponse<MemoCardResponse> update(
            @PathVariable Long memoId,
            @RequestBody SaveMemoRequest request
    ) {
        return ApiResponse.success(memoService.updateMemo(currentUserId(), memoId, request));
    }

    @DeleteMapping("/{memoId}")
    public ApiResponse<Boolean> delete(@PathVariable Long memoId) {
        return ApiResponse.success(memoService.deleteMemo(currentUserId(), memoId));
    }

    @GetMapping("/widget-summary")
    public ApiResponse<MemoSummaryResponse> widgetSummary() {
        return ApiResponse.success(memoService.getSummary(currentUserId(), 3));
    }

    private Long currentUserId() {
        Long userId = RequestUserContext.getUserId();
        if (userId == null) {
            throw new IllegalStateException("Missing authenticated user context");
        }
        return userId;
    }
}
