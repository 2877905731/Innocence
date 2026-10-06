package com.innocence.server.modules.assistant.service;

import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.assistant.mapper.AssistantMapper;
import com.innocence.server.modules.plan.service.StudyPlanService;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import com.innocence.server.modules.plan.dto.request.TodayPlanItemRequest;
import com.innocence.server.modules.focus.mapper.FocusSessionMapper;
import com.innocence.server.common.exception.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.*;
import java.util.*;

@Service
public class AssistantService {
    private final AssistantMapper store;
    private final AssistantCodec codec;
    private final ModelProviderAdapter provider;
    private final StudyPlanService plans;
    private final StudyPlanMapper planMapper;
    private final FocusSessionMapper focus;
    private final TransactionTemplate tx;
    public AssistantService(AssistantMapper store, AssistantCodec codec, ModelProviderAdapter provider,
                            StudyPlanService plans, StudyPlanMapper planMapper, FocusSessionMapper focus,
                            PlatformTransactionManager transactionManager) {
        this.store = store; this.codec = codec; this.provider = provider; this.plans = plans;
        this.planMapper = planMapper; this.focus = focus; this.tx = new TransactionTemplate(transactionManager);
    }

    public RequestResult generate(long owner, GenerateRequest request) {
        AssistantRules.request(request);
        String hash = hash(codec.write(request));
        StoredRequest claimed = tx.execute(status -> {
            planMapper.lockPlanningOwner(owner);
            requireActiveOwner(owner);
            StoredRequest old = loadOptional(owner, "request", request.clientRequestId(), StoredRequest.class);
            if (old != null) { sameHash(old.hash(), hash); return old; }
            if (store.recentRequests(owner) >= 4 || store.dailyRequests(owner) >= 30)
                throw new AssistantException(429, 1002, "QUOTA_EXCEEDED", "生成次数达到上限，请稍后再试。");
            StoredRequest value = new StoredRequest(hash, request, new RequestResult("pending", null, null));
            store.claim(owner, "request", request.clientRequestId(), codec.write(value)); return null;
        });
        if (claimed != null) return claimed.result();
        try {
            var snapshot = plans.getTodayPlan(owner, LocalDate.parse(request.planDate()));
            var precision = AssistantRules.precisionQuestions(request.instruction());
            ProviderPlan generated = precision.isEmpty() ? provider.generate(request, snapshot) :
                    new ProviderPlan("needs_input", precision, List.of("时间规则校验，尚未请求模型。"), List.of());
            if (generated == null || !Set.of("ready", "needs_input", "no_solution").contains(generated.status()))
                throw outputError();
            List<String> questions = textList(generated.questions()), assumptions = textList(generated.assumptions());
            List<Candidate> candidates = new ArrayList<>();
            if ("ready".equals(generated.status())) {
                if (generated.candidates() == null || generated.candidates().size() != 3) throw outputError();
                Set<String> intensities = new HashSet<>();
                for (ProviderCandidate value : generated.candidates()) {
                    if (value == null || !Set.of("conservative", "balanced", "compact").contains(value.intensity())
                            || !intensities.add(value.intensity()) || value.items() == null) throw outputError();
                    List<Task> tasks = value.items().stream().map(item -> new Task(UUID.randomUUID().toString(),
                            item.title(), item.startSlot(), item.endSlot())).toList();
                    try { if (!AssistantRules.conflicts(tasks, snapshot).isEmpty()) throw outputError(); }
                    catch (AssistantException error) { throw outputError(); }
                    candidates.add(new Candidate(UUID.randomUUID().toString(), value.intensity(), tasks, value.explanation()));
                }
            } else {
                if (generated.candidates() == null || !generated.candidates().isEmpty()) throw outputError();
                if ("needs_input".equals(generated.status()) && questions.isEmpty()) throw outputError();
                if ("no_solution".equals(generated.status()) && assumptions.isEmpty()) throw outputError();
            }
            Proposal proposal = new Proposal(UUID.randomUUID().toString(), 1, generated.status(), request.planDate(),
                    request.timeZone(), snapshot.getDayRevision(), Instant.now().plusSeconds(1800).toString(),
                    questions, assumptions, List.copyOf(candidates));
            RequestResult result = new RequestResult("complete", proposal, null);
            tx.executeWithoutResult(status -> {
                planMapper.lockPlanningOwner(owner); requireActiveOwner(owner);
                store.claim(owner, "proposal", proposal.proposalId(), codec.write(new StoredProposal(request, proposal)));
                store.update(owner, "request", request.clientRequestId(), codec.write(new StoredRequest(hash, request, result)));
            });
            return result;
        } catch (AssistantException error) {
            RequestResult failure = new RequestResult("failed", null, new Failure(error.reason(), error.getMessage()));
            store.update(owner, "request", request.clientRequestId(), codec.write(new StoredRequest(hash, request, failure)));
            throw error;
        } catch (Exception error) {
            RequestResult failure = new RequestResult("failed", null, new Failure("GENERATION_FAILURE", "生成失败，未修改任务。"));
            store.update(owner, "request", request.clientRequestId(), codec.write(new StoredRequest(hash, request, failure)));
            throw outputError();
        }
    }
    public RequestResult request(long owner, String id) {
        StoredRequest stored = load(owner, "request", AssistantRules.uuid(id), StoredRequest.class);
        if ("pending".equals(stored.result().requestStatus()) && store.abandonedRequest(owner, id) > 0)
            return new RequestResult("failed", null, new Failure("GENERATION_TIMEOUT", "请求未完成，请使用新请求标识重试。"));
        return stored.result();
    }
    public RequestResult clientProposal(long owner, ClientProposalRequest request) {
        if (request == null || request.sourceDayRevision() == null || request.sourceDayRevision() < 0)
            throw AssistantException.invalid("缺少当前日计划修订。");
        AssistantRules.uuid(request.clientRequestId());
        LocalDate date = AssistantRules.date(request.planDate(), request.timeZone());
        String inputHash = hash(codec.write(request));
        return tx.execute(status -> {
            planMapper.lockPlanningOwner(owner); requireActiveOwner(owner);
            var known = loadOptional(owner, "request", request.clientRequestId(), StoredRequest.class);
            if (known != null) { sameHash(known.hash(), inputHash); return known.result(); }
            var snapshot = plans.getTodayPlan(owner, date);
            if (snapshot.getDayRevision() != request.sourceDayRevision())
                throw AssistantException.conflict("STALE_PROPOSAL", "日计划已变化，请重新读取并规划。");
            var conflicts = AssistantRules.conflicts(request.items(), snapshot);
            if (!conflicts.isEmpty()) throw AssistantException.conflict("PLAN_CONFLICT", "新增时段重叠或容量不足。");
            var candidate = new Candidate(UUID.randomUUID().toString(), "balanced", List.copyOf(request.items()), "用户自带模型的聊天提案，需确认后应用。");
            var proposal = new Proposal(UUID.randomUUID().toString(), 1, "ready", request.planDate(), request.timeZone(),
                    snapshot.getDayRevision(), Instant.now().plusSeconds(1800).toString(), List.of(), List.of(), List.of(candidate));
            var origin = new GenerateRequest(request.clientRequestId(), "客户端聊天提案", request.planDate(), request.timeZone(), "model", "suggest");
            var result = new RequestResult("complete", proposal, null);
            store.claim(owner, "proposal", proposal.proposalId(), codec.write(new StoredProposal(origin, proposal)));
            store.claim(owner, "request", request.clientRequestId(), codec.write(new StoredRequest(inputHash, origin, result)));
            return result;
        });
    }
    public Validation validate(long owner, String id, ValidateRequest request) {
        if (request == null || request.proposalRevision() == null || request.candidateId() == null)
            throw AssistantException.invalid("请选择提案版本与候选计划。");
        return tx.execute(status -> {
            planMapper.lockPlanningOwner(owner);
            StoredProposal stored = lockedProposal(owner, id);
            Proposal proposal = stored.proposal(); checkProposal(proposal, request.proposalRevision());
            Candidate candidate = candidate(proposal, request.candidateId());
            List<Task> items = request.editedItems() == null ? candidate.items() : List.copyOf(request.editedItems());
            var snapshot = plans.getTodayPlan(owner, LocalDate.parse(proposal.planDate()));
            List<String> conflicts = new ArrayList<>(AssistantRules.conflicts(items, snapshot));
            if (snapshot.getDayRevision() != proposal.sourceDayRevision()) conflicts.add("日计划已变化，请重新生成。");
            int revision = proposal.proposalRevision();
            if (request.editedItems() != null) {
                revision++;
                Candidate edited = new Candidate(candidate.candidateId(), candidate.intensity(), items, candidate.explanation());
                List<Candidate> updated = proposal.candidates().stream().map(value ->
                        value.candidateId().equals(edited.candidateId()) ? edited : value).toList();
                proposal = new Proposal(proposal.proposalId(), revision, proposal.status(), proposal.planDate(), proposal.timeZone(),
                        proposal.sourceDayRevision(), proposal.expiresAt(), proposal.questions(), proposal.assumptions(), updated);
                store.update(owner, "proposal", id, codec.write(new StoredProposal(stored.request(), proposal)));
            }
            Validation validation = new Validation(UUID.randomUUID().toString(), proposal.proposalId(), revision, candidate.candidateId(),
                    snapshot.getDayRevision(), hash(codec.write(items)), proposal.expiresAt(), conflicts.isEmpty(), List.copyOf(conflicts), items);
            store.claim(owner, "validation", validation.validationId(), codec.write(validation)); return validation;
        });
    }
    public Execution execute(long owner, String id, ExecuteRequest request) {
        if (request == null || request.proposalRevision() == null) throw AssistantException.invalid("缺少执行字段。");
        AssistantRules.uuid(request.operationId()); AssistantRules.uuid(id); AssistantRules.uuid(request.validationId());
        String inputHash = hash(id + codec.write(request));
        var known = loadOptional(owner, "execution", request.operationId(), StoredExecution.class);
        if (known != null) { sameHash(known.hash(), inputHash);
            if (!"prepared".equals(known.execution().status())) return known.execution(); }
        StoredProposal initial = load(owner, "proposal", id, StoredProposal.class);
        return operation(owner, request.operationId(), inputHash, initial.proposal(), null, () -> tx.execute(status -> {
            planMapper.lockPlanningOwner(owner);
            StoredExecution previous = loadOptional(owner, "execution", request.operationId(), StoredExecution.class);
            if (previous != null) { sameHash(previous.hash(), inputHash);
                if (!"prepared".equals(previous.execution().status())) return previous.execution(); }
            StoredProposal stored = lockedProposal(owner, id); Proposal proposal = stored.proposal();
            checkProposal(proposal, request.proposalRevision()); candidate(proposal, request.candidateId());
            Validation validation = load(owner, "validation", request.validationId(), Validation.class);
            if (!validation.canExecute() || validation.proposalRevision() != proposal.proposalRevision()
                    || !validation.proposalId().equals(id)
                    || !validation.candidateId().equals(request.candidateId())
                    || !validation.changesHash().equals(hash(codec.write(candidate(proposal, request.candidateId()).items()))))
                throw AssistantException.conflict("STALE_PROPOSAL", "校验与提案不一致，请重新校验。");
            ensureFresh(validation.expiresAt());
            if (!"preview_apply".equals(request.authorizationKind()) && !"direct_add".equals(request.authorizationKind()))
                throw AssistantException.invalid("不支持的执行授权。");
            if ("direct_add".equals(request.authorizationKind()) && !directAuthorized(stored.request(), validation.items()))
                throw new AssistantException(403, 2001, "AUTHORIZATION_SCOPE_MISMATCH", "直接执行范围不明确，请先预览并应用。");
            LocalDate date = AssistantRules.date(proposal.planDate(), proposal.timeZone());
            var active = focus.findCurrentSessionByUserId(owner);
            if (active != null && date.equals(LocalDate.now(ZoneId.of(proposal.timeZone()))))
                throw AssistantException.conflict("ACTIVE_FOCUS", "当前有专注记录，请结束专注后应用今日新增。");
            List<TodayPlanItemRequest> additions = validation.items().stream().map(task -> {
                TodayPlanItemRequest value = new TodayPlanItemRequest(); value.setTitle(task.title());
                value.setStartSlot(task.startSlot()); value.setEndSlot(task.endSlot()); return value;
            }).toList();
            try {
                var added = plans.appendAssistantTasks(owner, date, proposal.sourceDayRevision(), additions);
                List<Change> changes = added.added().stream().map(item -> new Change(item.getId(), item.getTitle(),
                        item.getStartSlot(), item.getEndSlot())).toList();
                Execution execution = new Execution(request.operationId(), request.operationId(), id, proposal.proposalRevision(),
                        proposal.planDate(), "committed", proposal.sourceDayRevision(), added.plan().getDayRevision(), changes,
                        !changes.isEmpty(), Instant.now().toString(), null, added.createdPlan());
                store.update(owner, "execution", request.operationId(), codec.write(new StoredExecution(inputHash, execution)));
                return execution;
            } catch (BusinessException error) {
                throw AssistantException.conflict("STALE_DAY", "日计划已变化或时段冲突，请重新生成。");
            }
        }));
    }
    public Execution execution(long owner, String id) {
        return load(owner, "execution", AssistantRules.uuid(id), StoredExecution.class).execution();
    }
    public Execution undo(long owner, String id, UndoRequest request) {
        if (request == null || request.expectedAfterRevision() == null) throw AssistantException.invalid("缺少撤销版本。");
        AssistantRules.uuid(id); AssistantRules.uuid(request.operationId());
        String inputHash = hash("undo:" + id + codec.write(request));
        var known = loadOptional(owner, "execution", request.operationId(), StoredExecution.class);
        if (known != null) { sameHash(known.hash(), inputHash);
            if (!"prepared".equals(known.execution().status())) return known.execution(); }
        Execution source = execution(owner, id);
        Proposal initial = new Proposal(source.proposalId(), source.proposalRevision(), "ready", source.planDate(), "UTC",
                source.afterRevision(), Instant.now().plusSeconds(1800).toString(), List.of(), List.of(), List.of());
        return operation(owner, request.operationId(), inputHash, initial, id, () -> tx.execute(status -> {
            planMapper.lockPlanningOwner(owner);
            StoredExecution prior = loadOptional(owner, "execution", request.operationId(), StoredExecution.class);
            if (prior != null) { sameHash(prior.hash(), inputHash);
                if (!"prepared".equals(prior.execution().status())) return prior.execution(); }
            Execution original = execution(owner, id);
            if (!original.undoEligibility() || original.afterRevision() != request.expectedAfterRevision()
                    || original.undoOf() != null || focus.findCurrentSessionByUserId(owner) != null)
                throw AssistantException.conflict("UNDO_CONFLICT", "任务已有变化或专注，不能直接撤销。");
            try {
                var plan = plans.undoAssistantTasks(owner, LocalDate.parse(original.planDate()), original.afterRevision(),
                        original.actualChanges().stream().map(Change::itemId).toList(), original.createdPlan());
                Execution undone = new Execution(request.operationId(), request.operationId(), original.proposalId(),
                        original.proposalRevision(), original.planDate(), "committed", original.afterRevision(), plan.getDayRevision(),
                        original.actualChanges(), false, Instant.now().toString(), original.executionId(), false);
                store.update(owner, "execution", request.operationId(), codec.write(new StoredExecution(inputHash, undone)));
                return undone;
            } catch (BusinessException error) { throw AssistantException.conflict("UNDO_CONFLICT", "日计划已变化，不能覆盖新修改撤销。"); }
        }));
    }
    private Execution operation(long owner, String id, String hash, Proposal proposal, String undoOf,
                                java.util.function.Supplier<Execution> action) {
        Execution prepared = new Execution(id, id, proposal.proposalId(), proposal.proposalRevision(), proposal.planDate(),
                "prepared", proposal.sourceDayRevision(), proposal.sourceDayRevision(), List.of(), false,
                Instant.now().toString(), undoOf, false);
        Execution previous = tx.execute(status -> {
            planMapper.lockPlanningOwner(owner);
            requireActiveOwner(owner);
            var prior = loadOptional(owner, "execution", id, StoredExecution.class);
            if (prior != null) {
                sameHash(prior.hash(), hash);
                return "prepared".equals(prior.execution().status()) ? null : prior.execution();
            }
            store.claim(owner, "execution", id, codec.write(new StoredExecution(hash, prepared))); return null;
        });
        if (previous != null) return previous;
        try { return action.get(); }
        catch (RuntimeException error) {
            tx.executeWithoutResult(status -> {
                planMapper.lockPlanningOwner(owner);
                var current = loadOptional(owner, "execution", id, StoredExecution.class);
                if (current != null && "prepared".equals(current.execution().status())) {
                    var rejected = new Execution(id, id, prepared.proposalId(), prepared.proposalRevision(), prepared.planDate(),
                            "rejected", prepared.beforeRevision(), prepared.beforeRevision(), List.of(), false,
                            prepared.createdAt(), undoOf, false);
                    store.update(owner, "execution", id, codec.write(new StoredExecution(hash, rejected)));
                }
            });
            throw error;
        }
    }
    private StoredProposal lockedProposal(long owner, String id) {
        requireActiveOwner(owner);
        String json = store.lock(owner, "proposal", AssistantRules.uuid(id));
        if (json == null) throw AssistantException.missing(); return codec.read(json, StoredProposal.class);
    }
    private <T> T load(long owner, String kind, String id, Class<T> type) {
        T value = loadOptional(owner, kind, id, type); if (value == null) throw AssistantException.missing(); return value;
    }
    private void requireActiveOwner(long owner) {
        if (store.activeOwner(owner) != 1)
            throw new AssistantException(403, 2001, "PERMISSION_DENIED", "当前账号不可使用助手。");
    }
    private <T> T loadOptional(long owner, String kind, String id, Class<T> type) {
        if ("execution".equals(kind) && store.expired(owner, kind, id) > 0)
            throw new AssistantException(410, 4102, "OPERATION_EXPIRED", "操作记录已超过30天，不能重新执行。请重新规划。");
        String value = store.read(owner, kind, id); return value == null ? null : codec.read(value, type);
    }
    private void checkProposal(Proposal proposal, int revision) {
        ensureFresh(proposal.expiresAt()); AssistantRules.date(proposal.planDate(), proposal.timeZone());
        if (!"ready".equals(proposal.status()) || proposal.proposalRevision() != revision)
            throw AssistantException.conflict("STALE_PROPOSAL", "提案未就绪或版本已变化。");
    }
    private Candidate candidate(Proposal proposal, String id) {
        return proposal.candidates().stream().filter(value -> value.candidateId().equals(id)).findFirst()
                .orElseThrow(() -> AssistantException.invalid("候选计划不存在。"));
    }
    private void ensureFresh(String expires) {
        if (!Instant.parse(expires).isAfter(Instant.now())) throw AssistantException.conflict("STALE_PROPOSAL", "提案已过期，请重新生成。");
    }
    private boolean directAuthorized(GenerateRequest request, List<Task> tasks) {
        // Deliberately narrow deterministic grammar. Open-ended model interpretation never authorizes a write.
        if (!"direct_add".equals(request.requestedExecutionMode()) || tasks.size() != 1) return false;
        var pattern = java.util.regex.Pattern.compile("^直接新增 (\\d{4}-\\d{2}-\\d{2}) (\\d{2}:\\d{2})-(\\d{2}:\\d{2}) (.+)，保留已有任务$");
        var match = pattern.matcher(request.instruction().trim()); if (!match.matches()) return false;
        Task task = tasks.getFirst();
        try { return match.group(1).equals(request.planDate()) && match.group(3).equals(slot(task.endSlot()))
                && match.group(2).equals(slot(task.startSlot())) && match.group(4).equals(task.title()); }
        catch (Exception error) { return false; }
    }
    private String slot(int value) { return String.format(Locale.ROOT, "%02d:%02d", value / 2, value % 2 * 30); }
    private List<String> textList(List<String> values) {
        if (values == null) throw outputError();
        if (values.size() > 12 || values.stream().anyMatch(value -> value == null || value.length() > 2000)) throw outputError();
        return List.copyOf(values);
    }
    private AssistantException outputError() { return new AssistantException(503, 9101, "INVALID_MODEL_OUTPUT", "模型未返回有效计划，未修改任务。"); }
    private void sameHash(String prior, String current) {
        if (!prior.equals(current)) throw AssistantException.conflict("IDEMPOTENCY_CONFLICT", "同一操作标识不能用于不同内容。");
    }
    private String hash(String value) {
        try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8))); }
        catch (Exception error) { throw new IllegalStateException("Digest unavailable."); }
    }
}
