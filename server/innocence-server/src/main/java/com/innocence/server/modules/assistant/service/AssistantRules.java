package com.innocence.server.modules.assistant.service;

import com.innocence.server.modules.assistant.domain.AssistantModels.*;
import com.innocence.server.modules.plan.dto.response.TodayPlanResponse;
import java.time.*;
import java.util.*;

public final class AssistantRules {
    private AssistantRules() {}
    public static String uuid(String value) {
        try {
            if (value == null || !UUID.fromString(value).toString().equals(value.toLowerCase(Locale.ROOT)))
                throw new IllegalArgumentException();
            return value;
        } catch (Exception error) { throw AssistantException.invalid("操作标识必须为UUID。"); }
    }
    public static LocalDate date(String value, String timeZone) {
        try {
            LocalDate date = LocalDate.parse(value);
            LocalDate today = LocalDate.now(ZoneId.of(timeZone));
            if (date.isBefore(today) || date.isAfter(today.plusDays(30)))
                throw AssistantException.invalid("首批安排支持今天及未来30天内的单日。");
            return date;
        } catch (AssistantException error) { throw error; }
        catch (Exception error) { throw AssistantException.invalid("请提供明确日期与有效时区。"); }
    }
    public static void request(GenerateRequest request) {
        if (request == null) throw AssistantException.invalid("缺少助手请求。");
        uuid(request.clientRequestId()); date(request.planDate(), request.timeZone());
        if (request.instruction() == null || request.instruction().isBlank()
                || request.instruction().codePointCount(0, request.instruction().length()) > 2000)
            throw AssistantException.invalid("请输入不超过2000字的指令。");
        if (!"model".equals(request.generationMode()) || !Set.of("suggest", "direct_add").contains(
                request.requestedExecutionMode() == null ? "" : request.requestedExecutionMode()))
            throw AssistantException.invalid("不支持的生成或执行模式。");
    }
    public static List<String> precisionQuestions(String instruction) {
        var durations = java.util.regex.Pattern.compile("(?<![\\d.])(\\d+)\\s*(?:分钟|minutes?|min)(?![a-z])", java.util.regex.Pattern.CASE_INSENSITIVE).matcher(instruction);
        while (durations.find()) {
            try { if (Long.parseLong(durations.group(1)) % 30 != 0)
                return List.of("日计划采用30分钟网格，不能静默舍入该时长。请确认可用的半小时时长。"); }
            catch (NumberFormatException error) { return List.of("请提供可执行的任务时长。"); }
        }
        var times = java.util.regex.Pattern.compile("(?<!\\d)([0-2]?\\d):(\\d{2})(?!\\d)").matcher(instruction);
        while (times.find()) if (!Set.of("00", "30").contains(times.group(2)))
            return List.of("计划起止须为整点或半点，请确认时间；系统不会自动舍入。");
        return List.of();
    }
    public static List<String> conflicts(List<Task> tasks, TodayPlanResponse plan) {
        if (tasks == null || tasks.size() > 48) throw AssistantException.invalid("任务列表缺失或超过48项。");
        boolean[] occupied = new boolean[48];
        for (var item : plan.getItems()) {
            if (item.getStartSlot() != null && item.getEndSlot() != null)
                for (int slot = Math.max(0, item.getStartSlot()); slot < Math.min(48, item.getEndSlot()); slot++) occupied[slot] = true;
        }
        Set<String> ids = new HashSet<>();
        List<String> conflicts = new ArrayList<>();
        for (Task task : tasks) {
            if (task == null || task.title() == null || task.title().isBlank()
                    || task.title().codePointCount(0, task.title().length()) > 120
                    || task.startSlot() == null || task.endSlot() == null
                    || task.startSlot() < 0 || task.endSlot() > 48 || task.startSlot() >= task.endSlot())
                throw AssistantException.invalid("任务需非空标题和有效半小时时段。");
            uuid(task.clientEntityId());
            if (!ids.add(task.clientEntityId())) throw AssistantException.invalid("任务标识重复。");
            boolean overlap = false;
            for (int slot = task.startSlot(); slot < task.endSlot(); slot++) {
                overlap |= occupied[slot]; occupied[slot] = true;
            }
            if (overlap) conflicts.add(task.title() + " 与已有或新增安排重叠。");
        }
        long minutes = tasks.stream().mapToLong(task -> (task.endSlot() - task.startSlot()) * 30L).sum();
        if (minutes + plan.getTotalPlannedMinutes() > 1440) conflicts.add("总任务量超过24小时。");
        return List.copyOf(conflicts);
    }
}
