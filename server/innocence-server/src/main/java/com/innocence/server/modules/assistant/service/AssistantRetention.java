package com.innocence.server.modules.assistant.service;

import com.innocence.server.modules.assistant.mapper.AssistantMapper;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Configuration
@EnableScheduling
public class AssistantRetention {
    private final AssistantMapper store;
    public AssistantRetention(AssistantMapper store) { this.store = store; }
    @Scheduled(fixedDelay = 3600000, initialDelay = 60000)
    public void prune() { store.pruneDrafts(); store.redactExpiredExecutions(); }
}
