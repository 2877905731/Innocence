package com.innocence.server.common.exception;

public final class ErrorCode {

    private ErrorCode() {
    }

    public static final int BAD_REQUEST = 1000;
    public static final int VALIDATION_ERROR = 1001;
    public static final int TOO_MANY_REQUESTS = 1002;
    public static final int UNAUTHORIZED = 2000;
    public static final int FORBIDDEN = 2001;
    public static final int NOT_FOUND = 4004;
    public static final int INTERNAL_ERROR = 9000;
}
