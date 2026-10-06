package com.innocence.server.modules.assistant;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.assistant.controller.AssistantController;
import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.assistant.service.*;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import org.junit.jupiter.api.*;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import java.time.*;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class AssistantBoundaryTest {
    AssistantCodec codec=new AssistantCodec(new ObjectMapper().findAndRegisterModules());
    AssistantService service=mock(AssistantService.class);
    MockMvc mvc;
    @BeforeEach void setup(){mvc=MockMvcBuilders.standaloneSetup(new AssistantController(service,codec)).build();}
    @AfterEach void clear(){RequestUserContext.clear();}
    @Test void authenticationFailureIs401() throws Exception {
        mvc.perform(post("/api/app/v1/assistant/proposals").contentType("application/json").content("{}"))
            .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.data.reason").value("AUTHENTICATION_REQUIRED"));
        verifyNoInteractions(service);
    }
    @Test void missingFieldsCannotReachGeneration() throws Exception {
        RequestUserContext.setUserId(123L);
        doAnswer(call->{AssistantRules.request(call.getArgument(1));return null;}).when(service).generate(anyLong(),any());
        mvc.perform(post("/api/app/v1/assistant/proposals").contentType("application/json").content("{}"))
            .andExpect(status().isBadRequest()).andExpect(jsonPath("$.data.reason").value("INVALID_FIELD"));
    }
    @Test void editedNullAndPrivilegeFieldsAreRejected() throws Exception {
        RequestUserContext.setUserId(123L);String path="/api/app/v1/assistant/proposals/"+UUID.randomUUID()+"/validate";
        for(String body:List.of("{\"proposalRevision\":1,\"candidateId\":\"x\",\"editedItems\":null}",
                "{\"proposalRevision\":1,\"candidateId\":\"x\",\"owner\":999}",
                "{\"proposalRevision\":\"1\",\"candidateId\":\"x\"}")) {
            mvc.perform(post(path).contentType("application/json").content(body)).andExpect(status().isBadRequest());
        }
        verifyNoInteractions(service);
    }
    @Test void scalarCoercionDuplicatesAndFractionalSlotsFail() {
        for(String body:List.of("{\"startSlot\":1.5}","{\"startSlot\":\"2\"}","{\"startSlot\":1,\"startSlot\":2}")) {
            assertThrows(AssistantException.class,()->codec.read(body,Task.class));
        }
    }
    @Test void nonHalfHourAndCrossDaySlotsFail() {
        TodayPlanResponse plan=new TodayPlanResponse();plan.setItems(List.of());
        assertThrows(AssistantException.class,()->AssistantRules.conflicts(List.of(new Task(UUID.randomUUID().toString(),"任务",47,49)),plan));
        assertTrue(AssistantRules.conflicts(List.of(new Task(UUID.randomUUID().toString(),"任务",47,48)),plan).isEmpty());
        assertThrows(AssistantException.class,()->AssistantRules.date(LocalDate.now().minusDays(1).toString(),"Asia/Shanghai"));
    }
    @Test void noCredentialsFailsWithoutNetwork() {
        var provider=new CompatibleModelProvider(codec,false,"","","");
        assertEquals("AI_NOT_CONFIGURED",assertThrows(AssistantException.class,()->provider.generate(null,null)).reason());
    }
    @Test void clientProposalAuthenticationPrivilegeAndCoercionBoundary() throws Exception {
        String path = "/api/app/v1/assistant/client-proposals";
        mvc.perform(post(path).contentType("application/json").content("{}"))
                .andExpect(status().isUnauthorized());
        RequestUserContext.setUserId(123L);
        for (String body : List.of("{\"ownerScope\":\"other\"}", "{\"userId\":123}",
                "{\"sourceDayRevision\":\"1\"}", "{\"sourceDayRevision\":1.5}")) {
            mvc.perform(post(path).contentType("application/json").content(body)).andExpect(status().isBadRequest());
        }
        verifyNoInteractions(service);
    }
}
