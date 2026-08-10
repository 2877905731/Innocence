package com.innocence.server.modules.account.dto.response;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;

class CurrentSessionResponseTest {

    @Test
    void doesNotSerializeSessionToken() throws Exception {
        CurrentSessionResponse response = new CurrentSessionResponse();
        response.setDeviceType("windows");
        response.setSessionToken("synthetic-session-token");

        String json = new ObjectMapper().writeValueAsString(response);

        assertFalse(json.contains("sessionToken"));
        assertFalse(json.contains("synthetic-session-token"));
    }
}
