package com.innocence.server.modules.assistant.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.assistant.service.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.OffsetDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/app/v1/assistant")
public class AssistantController {
    private final AssistantService service;
    private final AssistantCodec codec;
    public AssistantController(AssistantService service, AssistantCodec codec) { this.service = service; this.codec = codec; }
    private long owner() {
        Long owner = RequestUserContext.getUserId();
        if (owner == null) throw new AssistantException(401, 2000, "AUTHENTICATION_REQUIRED", "请先登录当前账号。");
        return owner;
    }
    @PostMapping("/proposals") public ApiResponse<RequestResult> generate(@RequestBody String body) {
        long owner = owner(); return ApiResponse.success(service.generate(owner, codec.read(body, GenerateRequest.class)));
    }
    @PostMapping("/client-proposals") public ApiResponse<RequestResult> clientProposal(@RequestBody String body) {
        long owner = owner(); return ApiResponse.success(service.clientProposal(owner, codec.read(body, ClientProposalRequest.class)));
    }
    @GetMapping("/requests/{id}") public ApiResponse<RequestResult> request(@PathVariable String id) {
        return ApiResponse.success(service.request(owner(), id));
    }
    @PostMapping("/proposals/{id}/validate") public ApiResponse<Validation> validate(@PathVariable String id, @RequestBody String body) {
        long owner = owner(); codec.validateBody(body);
        return ApiResponse.success(service.validate(owner, id, codec.read(body, ValidateRequest.class)));
    }
    @PostMapping("/proposals/{id}/execute") public ApiResponse<Execution> execute(@PathVariable String id, @RequestBody String body) {
        long owner = owner(); return ApiResponse.success(service.execute(owner, id, codec.read(body, ExecuteRequest.class)));
    }
    @GetMapping("/executions/{id}") public ApiResponse<Execution> execution(@PathVariable String id) {
        return ApiResponse.success(service.execution(owner(), id));
    }
    @PostMapping("/executions/{id}/undo") public ApiResponse<Execution> undo(@PathVariable String id, @RequestBody String body) {
        long owner = owner(); return ApiResponse.success(service.undo(owner, id, codec.read(body, UndoRequest.class)));
    }
    @ExceptionHandler(AssistantException.class) public ResponseEntity<ApiResponse<Map<String, Object>>> failure(AssistantException error) {
        var response = ResponseEntity.status(error.status());
        if (error.status() == 429) response.header("Retry-After", "60");
        return response.body(new ApiResponse<>(error.code(), error.getMessage(),
                Map.of("reason", error.reason(), "fieldErrors", java.util.List.of()), "", OffsetDateTime.now()));
    }
}
