package com.innocence.server.common.web;

import com.innocence.server.common.api.ApiResponse;
import org.junit.jupiter.api.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.annotation.*;
import ch.qos.logback.classic.Logger;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.read.ListAppender;
import org.slf4j.LoggerFactory;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class RequestTraceFilterTest {
    @RestController static class FixtureController {
        @PostMapping("/api/app/v1/plans/annual-segments")
        ApiResponse<String> write(@RequestBody Map<String, Object> ignored) { return ApiResponse.success("accepted"); }
    }
    MockMvc mvc = MockMvcBuilders.standaloneSetup(new FixtureController())
        .setControllerAdvice(new GlobalExceptionHandler()).addFilter(new RequestTraceFilter()).build();
    @Test void validatedTraceIsReturnedInBodyAndHeaderAndCannotLeakToTheNextRequest() throws Exception {
        String id = "11111111-1111-4111-8111-111111111111";
        mvc.perform(post("/api/app/v1/plans/annual-segments").header("X-Request-ID", id)
            .contentType("application/json").content("{}"))
            .andExpect(status().isOk()).andExpect(header().string("X-Request-ID", id)).andExpect(jsonPath("$.requestId").value(id));
        assertNotEquals(id, RequestTrace.currentId());
        String next = mvc.perform(post("/api/app/v1/plans/annual-segments").contentType("application/json").content("{}"))
            .andReturn().getResponse().getHeader("X-Request-ID");
        assertNotNull(next); assertNotEquals(id, next);
    }
    @Test void invalidHeadersAndRequestContentAreNotCopiedIntoDiagnosticLogs() throws Exception {
        Logger logger = (Logger) LoggerFactory.getLogger(RequestTraceFilter.class);
        ListAppender<ILoggingEvent> appender = new ListAppender<>(); appender.start(); logger.addAppender(appender);
        try {
            var response = mvc.perform(post("/api/app/v1/plans/annual-segments?privateQuery=private-query-value")
                .header("X-Request-ID", "private@example.invalid").header("X-Client-Entity-ID", "private-identity")
                .contentType("application/json").content("{\"note\":\"private-note-value\",\"apiKey\":\"synthetic-secret-value\"}"))
                .andExpect(status().isOk()).andReturn().getResponse();
            assertTrue(response.getHeader("X-Request-ID").matches("[0-9a-f-]{36}"));
            String log = appender.list.stream().map(ILoggingEvent::getFormattedMessage).reduce("", String::concat);
            for (String value : new String[]{"private@example.invalid", "private-identity", "private-note-value", "synthetic-secret-value", "private-query-value"})
                assertFalse(log.contains(value), value);
            assertTrue(log.contains("status=200"));
        } finally { logger.detachAppender(appender); appender.stop(); }
    }
    @Test void malformedJsonReturnsAUseful400WithACorrelationId() throws Exception {
        mvc.perform(post("/api/app/v1/plans/annual-segments").contentType("application/json").content("not-json"))
            .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value(1001))
            .andExpect(jsonPath("$.message").isNotEmpty()).andExpect(jsonPath("$.requestId").isNotEmpty());
    }
}
