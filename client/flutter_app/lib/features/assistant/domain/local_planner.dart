import '../../plans/domain/models/today_plan.dart';
import 'assistant_models.dart';

/// Deterministic scheduling only. It does not infer intent from arbitrary prose.
class LocalPlanner {
  AssistantProposal generate(
      TodayPlan plan, String instruction, int start, int end) {
    assistantDate(plan.planDate);
    final direct = assistantDirect(instruction, plan.planDate);
    if (direct != null) {
      final item =
          AssistantTask(assistantId(), direct.title, direct.start, direct.end);
      final conflicts = assistantConflicts([item], plan);
      return AssistantProposal(
          id: assistantId(),
          revision: 1,
          status: conflicts.isEmpty ? 'ready' : 'no_solution',
          planDate: plan.planDate,
          timeZone: 'device-local',
          sourceRevision: plan.dayRevision,
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
          questions: const [],
          assumptions: [
            '离线规则排程 / Offline rule planner',
            '按明确指令使用固定任务与时段 / Exact task and time from your command',
            ...conflicts
          ],
          candidates: conflicts.isNotEmpty
              ? const []
              : ['conservative', 'balanced', 'compact']
                  .map((mode) => AssistantCandidate(assistantId(), mode, [item],
                      '固定时段一致，直接新增且保留已有任务 / Same fixed time; add only.'))
                  .toList());
    }
    if (instruction.trim().isEmpty ||
        instruction.runes.length > 2000 ||
        start < 0 ||
        end > 48 ||
        start >= end) {
      throw const FormatException(
          '请填写任务和有效可用时段 / Enter tasks and a valid time window.');
    }
    final tasks = <({String title, int slots})>[];
    final questions = <String>[];
    for (final part in instruction
        .split(RegExp(r'[；;\n]'))
        .where((p) => p.trim().isNotEmpty)) {
      final match =
          RegExp(r'^\s*(.+?)\s+(\d+)\s*(?:分钟|min)\s*$', caseSensitive: false)
              .firstMatch(part);
      if (match == null) {
        questions.add('请使用“任务名 60分钟”或“Task 60 min”，多项用分号分隔。');
        continue;
      }
      final title = match[1]!.trim();
      final minutes = int.parse(match[2]!);
      if (minutes <= 0 ||
          minutes % 30 != 0 ||
          minutes > 1440 ||
          title.runes.length > 120) {
        questions
            .add('$title：时长须为30分钟倍数，标题最多120字 / Use multiples of 30 minutes.');
        continue;
      }
      tasks.add((title: title, slots: minutes ~/ 30));
    }
    if (tasks.isEmpty || tasks.length > 48) {
      questions.add('请提供1–48项任务 / Provide 1–48 tasks.');
    }
    final candidates = <AssistantCandidate>[];
    if (questions.isEmpty) {
      for (final strategy in [
        ('conservative', 2),
        ('balanced', 1),
        ('compact', 0)
      ]) {
        final occupied = List.filled(48, false);
        for (final task in plan.scheduledItems) {
          for (var s = task.startSlot!.clamp(0, 48);
              s < task.endSlot!.clamp(0, 48);
              s++) {
            occupied[s] = true;
          }
        }
        final additions = <AssistantTask>[];
        final missing = <String>[];
        var cursor = start;
        var workload = plan.totalPlannedMinutes;
        for (final task in tasks) {
          int? chosen;
          if (workload + task.slots * 30 <= 1440) {
            for (var s = cursor; s + task.slots <= end; s++) {
              if (!occupied.sublist(s, s + task.slots).any((v) => v)) {
                chosen = s;
                break;
              }
            }
          }
          if (chosen == null) {
            missing.add(task.title);
            continue;
          }
          additions.add(AssistantTask(
              assistantId(), task.title, chosen, chosen + task.slots));
          workload += task.slots * 30;
          cursor = chosen + task.slots + strategy.$2;
        }
        candidates.add(AssistantCandidate(
            assistantId(),
            strategy.$1,
            List.unmodifiable(additions),
            '任务间预留 ${strategy.$2 * 30} min；保留所有已有任务。'
            '${missing.isEmpty ? '' : '容量不足，未安排 / Unscheduled: ${missing.join('、')}'}'));
      }
    }
    return AssistantProposal(
        id: assistantId(),
        revision: 1,
        status: questions.isNotEmpty
            ? 'needs_input'
            : candidates.every((c) => c.items.isEmpty)
                ? 'no_solution'
                : 'ready',
        planDate: plan.planDate,
        timeZone: 'device-local',
        sourceRevision: plan.dayRevision,
        expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 30)),
        questions: List.unmodifiable(questions),
        assumptions: [
          '离线规则排程 / Offline rule planner',
          '按输入顺序安排；仅使用 ${TodayPlan.slotLabel(start)}–${TodayPlan.slotLabel(end)} / Input order and chosen window.',
          '已有未定时任务只计入总工作量，不推断其占用时段 / Flexible tasks count toward capacity.'
        ],
        candidates:
            questions.isNotEmpty || candidates.every((c) => c.items.isEmpty)
                ? const []
                : List.unmodifiable(candidates));
  }
}
