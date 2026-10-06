package com.innocence.server.modules.assistant.domain;

import java.util.List;

/** Typed boundary between a provider, planning rules and persisted operations. */
public final class AssistantModels {
    public record ClientProposalRequest(String clientRequestId, String planDate, String timeZone,
                                        Long sourceDayRevision, java.util.List<Task> items) {}
    private AssistantModels() {}

    public record GenerateRequest(String clientRequestId, String instruction, String planDate,
                                  String timeZone, String generationMode, String requestedExecutionMode) {}
    public record Task(String clientEntityId, String title, Integer startSlot, Integer endSlot) {}
    public record Candidate(String candidateId, String intensity, List<Task> items, String explanation) {}
    public record Proposal(String proposalId, int proposalRevision, String status, String planDate,
                           String timeZone, long sourceDayRevision, String expiresAt,
                           List<String> questions, List<String> assumptions, List<Candidate> candidates) {}
    public record Failure(String reason, String message) {}
    public record RequestResult(String requestStatus, Proposal proposal, Failure failure) {}
    public record StoredRequest(String hash, GenerateRequest request, RequestResult result) {}
    public record StoredProposal(GenerateRequest request, Proposal proposal) {}
    public record ValidateRequest(Integer proposalRevision, String candidateId, List<Task> editedItems) {}
    public record Validation(String validationId, String proposalId, int proposalRevision, String candidateId,
                             long sourceDayRevision, String changesHash, String expiresAt,
                             boolean canExecute, List<String> conflicts, List<Task> items) {}
    public record ExecuteRequest(String operationId, Integer proposalRevision, String candidateId,
                                 String validationId, String authorizationKind) {}
    public record UndoRequest(String operationId, Long expectedAfterRevision) {}
    public record Change(long itemId, String title, int startSlot, int endSlot) {}
    public record Execution(String executionId, String operationId, String proposalId,
                            int proposalRevision, String planDate, String status, long beforeRevision,
                            long afterRevision, List<Change> actualChanges, boolean undoEligibility,
                            String createdAt, String undoOf, boolean createdPlan) {}
    public record StoredExecution(String hash, Execution execution) {}
    public record ProviderTask(String title, Integer startSlot, Integer endSlot) {}
    public record ProviderCandidate(String intensity, List<ProviderTask> items, String explanation) {}
    public record ProviderPlan(String status, List<String> questions, List<String> assumptions,
                               List<ProviderCandidate> candidates) {}
}
