package com.innocence.server.common.api;

import java.time.OffsetDateTime;

public record ApiResponse<T>(
        int code,
        String message,
        T data,
        String requestId,
        OffsetDateTime serverTime
) {

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(0, "ok", data, "", OffsetDateTime.now());
    }

    public static <T> ApiResponse<T> fail(int code, String message) {
        return new ApiResponse<>(code, message, null, "", OffsetDateTime.now());
    }
}
