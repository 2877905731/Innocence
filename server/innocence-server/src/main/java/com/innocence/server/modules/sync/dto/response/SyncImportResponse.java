package com.innocence.server.modules.sync.dto.response;

import java.util.List;

public record SyncImportResponse(
        int acceptedCount,
        int rejectedCount,
        int conflictCount,
        List<SyncImportItemResponse> items
) {
}
