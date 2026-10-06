package com.innocence.server.modules.assistant;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.assistant.service.*;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import com.sun.net.httpserver.HttpServer;
import org.junit.jupiter.api.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
import static org.junit.jupiter.api.Assertions.*;

/** Local HTTP protocol fixtures; does not assert live model quality. */
class CompatibleModelProviderTest {
    HttpServer server;
    final AssistantCodec codec=new AssistantCodec(new ObjectMapper().findAndRegisterModules());
    int status=200;String response;
    CompatibleModelProvider provider;
    @BeforeEach void start() throws Exception {
        server=HttpServer.create(new InetSocketAddress("127.0.0.1",0),0);
        server.createContext("/chat",exchange->{
            assertEquals("Bearer synthetic-test-key",exchange.getRequestHeaders().getFirst("Authorization"));
            String request=new String(exchange.getRequestBody().readAllBytes(),StandardCharsets.UTF_8);
            assertTrue(request.contains("json_object"));assertFalse(request.contains("password"));
            byte[] bytes=response.getBytes(StandardCharsets.UTF_8);exchange.sendResponseHeaders(status,bytes.length);
            exchange.getResponseBody().write(bytes);exchange.close();
        });server.start();
        provider=new CompatibleModelProvider(codec,true,"http://127.0.0.1:"+server.getAddress().getPort()+"/chat","synthetic-test-key","fixture-model");
    }
    @AfterEach void stop(){server.stop(0);}
    ProviderPlan generate(){var plan=new TodayPlanResponse();plan.setItems(List.of());
        return provider.generate(new GenerateRequest(UUID.randomUUID().toString(),"Plan tasks","2026-10-04","Asia/Shanghai","model","suggest"),plan);}
    @Test void validJsonModeContentIsMappedToInternalModel(){
        String content=codec.write(new ProviderPlan("needs_input",List.of("Available time?"),List.of(),List.of()));
        response=codec.write(Map.of("choices",List.of(Map.of("finish_reason","stop","message",Map.of("content",content))),"usage",Map.of("tokens",1)));
        assertEquals("needs_input",generate().status());
    }
    @Test void invalidJsonTruncationAndRefusalAreSanitized(){
        for(String body:List.of("<html>invalid upstream</html>",
            codec.write(Map.of("choices",List.of(Map.of("finish_reason","length","message",Map.of("content","{}"))))),
            codec.write(Map.of("choices",List.of(Map.of("finish_reason","stop","message",Map.of("content","{}","refusal","private upstream text"))))))) {
            response=body;var error=assertThrows(AssistantException.class,()->generate());
            assertEquals("INVALID_MODEL_OUTPUT",error.reason());assertFalse(error.getMessage().contains("private"));
        }
    }
    @Test void upstreamQuotaAndServerFailuresAreExplicit(){
        response="private upstream payload";status=429;assertEquals(429,assertThrows(AssistantException.class,()->generate()).status());
        status=500;assertEquals("MODEL_UNAVAILABLE",assertThrows(AssistantException.class,()->generate()).reason());
    }
}
