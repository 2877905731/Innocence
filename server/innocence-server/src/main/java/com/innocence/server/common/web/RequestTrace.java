package com.innocence.server.common.web;

import java.util.UUID;

public final class RequestTrace {
    private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();
    private RequestTrace() {}
    static void bind(String id) { CURRENT.set(id); }
    static void clear() { CURRENT.remove(); }
    public static String currentId() {
        String id = CURRENT.get();
        return id == null ? UUID.randomUUID().toString() : id;
    }
}
