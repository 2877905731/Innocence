package com.innocence.server.modules.plan.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.plan.dto.request.ReorderPlanRequest;
import com.innocence.server.modules.plan.mapper.StudyPlanMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
public class PlanOrderService {
    private final StudyPlanMapper mapper;
    private final StudyPlanService plans;

    public PlanOrderService(StudyPlanMapper mapper, StudyPlanService plans) {
        this.mapper = mapper;
        this.plans = plans;
    }

    @Transactional
    public void reorder(Long owner, ReorderPlanRequest request) {
        var ids = request.items().stream().map(ReorderPlanRequest.Item::id).toList();
        if (new HashSet<>(ids).size() != ids.size()) invalid();
        switch (request.scope()) {
            case "today" -> {
                if (request.planDate() == null || request.baseRevision() == null) invalid();
                long revision = plans.lockDay(owner, request.planDate());
                if (revision != request.baseRevision()) conflict();
                var plan = mapper.findDailyPlanByUserIdAndDate(owner, request.planDate());
                if (plan == null) throw new BusinessException(ErrorCode.NOT_FOUND, "日计划不存在。");
                var existing = mapper.findDailyPlanItemsByPlanId(plan.getId());
                sameIds(ids, existing.stream().map(item -> item.getId()).toList());
                for (int i = 0; i < ids.size(); i++) mapper.reorderDailyItem(owner, plan.getId(), ids.get(i), i);
                mapper.advanceDayRevision(owner, request.planDate());
            }
            case "annual" -> {
                if (request.year() == null) invalid();
                mapper.lockPlanningOwner(owner);
                var existing = mapper.findAnnualSegmentsByUserIdAndYear(owner, request.year());
                sameIds(ids, existing.stream().map(item -> item.getId()).toList());
                var revisions = new HashMap<Long, Integer>();
                existing.forEach(item -> revisions.put(item.getId(), item.getRevision()));
                for (var item : request.items()) {
                    if (item.revision() == null) invalid();
                    if (!Objects.equals(item.revision(), revisions.get(item.id()))) conflict();
                }
                for (int i = 0; i < ids.size(); i++) mapper.reorderAnnualSegment(owner, ids.get(i), i);
            }
            case "subtasks" -> {
                if (request.segmentId() == null || request.baseRevision() == null) invalid();
                mapper.lockPlanningOwner(owner);
                var parent = mapper.findAnnualSegmentByIdAndUserId(request.segmentId(), owner);
                if (parent == null) throw new BusinessException(ErrorCode.NOT_FOUND, "年度任务不存在。");
                if (parent.getRevision().longValue() != request.baseRevision()) conflict();
                var existing = mapper.findAnnualPlanSubtasksBySegmentId(parent.getId(), owner);
                sameIds(ids, existing.stream().map(item -> item.getId()).toList());
                for (int i = 0; i < ids.size(); i++) mapper.reorderAnnualSubtask(owner, parent.getId(), ids.get(i), i);
                mapper.advanceAnnualRevision(owner, parent.getId());
            }
            default -> invalid();
        }
    }

    private void sameIds(List<Long> supplied, List<Long> existing) {
        if (supplied.size() != existing.size() || !new HashSet<>(supplied).equals(new HashSet<>(existing))) invalid();
    }
    private void invalid() {
        throw new BusinessException(ErrorCode.VALIDATION_ERROR, "排序范围或任务标识无效，请重新打开排序。");
    }
    private void conflict() {
        throw new BusinessException(ErrorCode.BAD_REQUEST, "计划已变化，请重新打开排序。");
    }
}
