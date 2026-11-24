package com.innocence.server.modules.plan.controller;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.plan.dto.request.ReorderPlanRequest;
import com.innocence.server.modules.plan.service.PlanOrderService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/app/v1/plans")
public class PlanOrderController {
    private final PlanOrderService service;
    public PlanOrderController(PlanOrderService service) { this.service = service; }
    @PutMapping("/reorder")
    public ApiResponse<Boolean> reorder(@Valid @RequestBody ReorderPlanRequest request) {
        service.reorder(RequestUserContext.getUserId(), request);
        return ApiResponse.success(true);
    }
}
