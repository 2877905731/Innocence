package com.innocence.server.modules.assistant.service;

import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;

public interface ModelProviderAdapter {
    ProviderPlan generate(GenerateRequest request, TodayPlanResponse snapshot);
}
