package com.innocence.server.modules.assistant.service;

public final class AssistantException extends RuntimeException {
    private final int status;
    private final int code;
    private final String reason;
    public AssistantException(int status, int code, String reason, String message) {
        super(message);
        this.status = status;
        this.code = code;
        this.reason = reason;
    }
    public int status() { return status; }
    public int code() { return code; }
    public String reason() { return reason; }
    public static AssistantException invalid(String message) {
        return new AssistantException(400, 1001, "INVALID_FIELD", message);
    }
    public static AssistantException conflict(String reason, String message) {
        return new AssistantException(409, 4101, reason, message);
    }
    public static AssistantException missing() {
        return new AssistantException(404, 4004, "RESOURCE_NOT_FOUND", "未找到当前账号的助手记录。");
    }
}
