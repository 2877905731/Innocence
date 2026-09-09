package com.innocence.server.modules.sync.dto.response;

import java.util.List;

public record SyncImportPreviewResponse(
        long targetUserId,
        String targetUserNo,
        String targetNickname,
        int pendingOperationCount,
        int conflictCount,
        List<String> dailyPlanConflictDates
) {
}
