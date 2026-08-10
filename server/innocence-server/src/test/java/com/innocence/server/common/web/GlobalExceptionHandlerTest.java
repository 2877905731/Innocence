package com.innocence.server.common.web;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class GlobalExceptionHandlerTest {

    private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    @Test
    void mapsInternalBusinessFailureToHttp500() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleBusiness(
                new BusinessException(ErrorCode.INTERNAL_ERROR, "synthetic storage failure")
        );

        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.INTERNAL_ERROR, response.getBody().code());
    }

    @Test
    void keepsBadRequestBusinessFailureAtHttp400() {
        ResponseEntity<ApiResponse<Void>> response = handler.handleBusiness(
                new BusinessException(ErrorCode.BAD_REQUEST, "synthetic validation failure")
        );

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals(ErrorCode.BAD_REQUEST, response.getBody().code());
    }
}
