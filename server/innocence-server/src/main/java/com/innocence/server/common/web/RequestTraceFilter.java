package com.innocence.server.common.web;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.HandlerMapping;
import java.io.IOException;
import java.util.UUID;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestTraceFilter extends OncePerRequestFilter {
    private static final Logger LOG = LoggerFactory.getLogger(RequestTraceFilter.class);
    private static String safeUuid(String value) {
        return value != null && value.matches("[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}") ? value : "";
    }
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String id = safeUuid(request.getHeader("X-Request-ID"));
        if (id.isEmpty()) id = UUID.randomUUID().toString();
        String entity = safeUuid(request.getHeader("X-Client-Entity-ID"));
        RequestTrace.bind(id);
        response.setHeader("X-Request-ID", id);
        long started = System.nanoTime();
        try { chain.doFilter(request, response); }
        finally {
            Object matched = request.getAttribute(HandlerMapping.BEST_MATCHING_PATTERN_ATTRIBUTE);
            String route = matched == null ? "unmatched" : matched.toString();
            if (route.contains("annual-segments") || response.getStatus() >= 400) {
                // Only static route templates and validated identifiers: no body, query, credentials or user data.
                LOG.info("requestId={} clientEntityId={} method={} route={} status={} durationMs={}",
                    id, entity, request.getMethod(), route, response.getStatus(), (System.nanoTime() - started) / 1_000_000);
            }
            RequestTrace.clear();
        }
    }
}
