import 'dart:math';
import '../../plans/domain/models/today_plan.dart';

String assistantId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

({String title, int start, int end})? assistantDirect(
    String instruction, String date) {
  final match = RegExp(
          r'^直接新增 (\d{4}-\d{2}-\d{2}) (\d{2}:\d{2})-(\d{2}:\d{2}) (.+)，保留已有任务$')
      .firstMatch(instruction.trim());
  if (match == null) return null;
  if (match[1] != date) {
    throw const FormatException(
        '指令日期与目标日期不一致 / Command date differs from target date.');
  }
  final start = assistantSlot(match[2]!),
      end = assistantSlot(match[3]!, end: true);
  final title = match[4]!.trim();
  if (start >= end || title.isEmpty || title.runes.length > 120) {
    throw const FormatException('直接新增指令的任务或时段无效 / Invalid direct-add command.');
  }
  return (title: title, start: start, end: end);
}

class AssistantTask {
  const AssistantTask(this.id, this.title, this.startSlot, this.endSlot);
  final String id, title;
  final int startSlot, endSlot;
  factory AssistantTask.fromJson(Map<String, dynamic> j) => AssistantTask(
      j['clientEntityId'] as String,
      j['title'] as String,
      j['startSlot'] as int,
      j['endSlot'] as int);
  Map<String, dynamic> toJson() => {
        'clientEntityId': id,
        'title': title,
        'startSlot': startSlot,
        'endSlot': endSlot
      };
  String get timeLabel =>
      '${TodayPlan.slotLabel(startSlot)}–${TodayPlan.slotLabel(endSlot)}';
}

class AssistantCandidate {
  const AssistantCandidate(
      this.id, this.intensity, this.items, this.explanation);
  final String id, intensity, explanation;
  final List<AssistantTask> items;
  factory AssistantCandidate.fromJson(
          Map<String, dynamic> j) =>
      AssistantCandidate(
          j['candidateId'] as String,
          j['intensity'] as String,
          (j['items'] as List)
              .map((v) =>
                  AssistantTask.fromJson(Map<String, dynamic>.from(v as Map)))
              .toList(),
          j['explanation'] as String? ?? '');
  Map<String, dynamic> toJson() => {
        'candidateId': id,
        'intensity': intensity,
        'items': items.map((v) => v.toJson()).toList(),
        'explanation': explanation
      };
}

class AssistantProposal {
  const AssistantProposal(
      {required this.id,
      required this.revision,
      required this.status,
      required this.planDate,
      required this.timeZone,
      required this.sourceRevision,
      required this.expiresAt,
      required this.questions,
      required this.assumptions,
      required this.candidates});
  final String id, status, planDate, timeZone;
  final int revision, sourceRevision;
  final DateTime expiresAt;
  final List<String> questions, assumptions;
  final List<AssistantCandidate> candidates;
  factory AssistantProposal.fromJson(Map<String, dynamic> j) =>
      AssistantProposal(
          id: j['proposalId'] as String,
          revision: j['proposalRevision'] as int,
          status: j['status'] as String,
          planDate: j['planDate'] as String,
          timeZone: j['timeZone'] as String,
          sourceRevision: j['sourceDayRevision'] as int,
          expiresAt: DateTime.parse(j['expiresAt'] as String),
          questions: List<String>.from(j['questions'] as List),
          assumptions: List<String>.from(j['assumptions'] as List),
          candidates: (j['candidates'] as List)
              .map((v) => AssistantCandidate.fromJson(
                  Map<String, dynamic>.from(v as Map)))
              .toList());
  Map<String, dynamic> toJson() => {
        'proposalId': id,
        'proposalRevision': revision,
        'status': status,
        'planDate': planDate,
        'timeZone': timeZone,
        'sourceDayRevision': sourceRevision,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'questions': questions,
        'assumptions': assumptions,
        'candidates': candidates.map((v) => v.toJson()).toList()
      };
}

class AssistantValidation {
  const AssistantValidation(
      this.id, this.revision, this.canExecute, this.conflicts, this.items);
  final String id;
  final int revision;
  final bool canExecute;
  final List<String> conflicts;
  final List<AssistantTask> items;
  factory AssistantValidation.fromJson(Map<String, dynamic> j) =>
      AssistantValidation(
          j['validationId'] as String,
          j['proposalRevision'] as int,
          j['canExecute'] as bool,
          List<String>.from(j['conflicts'] as List),
          (j['items'] as List)
              .map((v) =>
                  AssistantTask.fromJson(Map<String, dynamic>.from(v as Map)))
              .toList());
}

class AssistantExecution {
  const AssistantExecution(this.id, this.status, this.planDate,
      this.afterRevision, this.undoEligibility, this.changes, this.undoOf);
  final String id, status, planDate;
  final int afterRevision;
  final bool undoEligibility;
  final List<Map<String, dynamic>> changes;
  final String? undoOf;
  factory AssistantExecution.fromJson(
          Map<String, dynamic> j) =>
      AssistantExecution(
          j['executionId'] as String,
          j['status'] as String,
          j['planDate'] as String,
          j['afterRevision'] as int,
          j['undoEligibility'] as bool,
          (j['actualChanges'] as List)
              .map((v) => Map<String, dynamic>.from(v as Map))
              .toList(),
          j['undoOf'] as String?);
  Map<String, dynamic> toJson() => {
        'executionId': id,
        'status': status,
        'planDate': planDate,
        'afterRevision': afterRevision,
        'undoEligibility': undoEligibility,
        'actualChanges': changes,
        'undoOf': undoOf
      };
}

List<String> assistantConflicts(List<AssistantTask> tasks, TodayPlan plan) {
  if (tasks.length > 48) {
    throw const FormatException('最多48项任务 / Maximum 48 tasks.');
  }
  final occupied = List.filled(48, false);
  for (final item in plan.items.where((i) => i.hasSchedule)) {
    for (var s = item.startSlot!.clamp(0, 48);
        s < item.endSlot!.clamp(0, 48);
        s++) {
      occupied[s] = true;
    }
  }
  final ids = <String>{};
  final conflicts = <String>[];
  for (final task in tasks) {
    if (task.title.trim().isEmpty ||
        task.title.runes.length > 120 ||
        task.startSlot < 0 ||
        task.endSlot > 48 ||
        task.startSlot >= task.endSlot ||
        !ids.add(task.id)) {
      throw const FormatException(
          '任务标题或半小时时段无效 / Invalid task or half-hour slots.');
    }
    var overlap = false;
    for (var s = task.startSlot; s < task.endSlot; s++) {
      overlap |= occupied[s];
      occupied[s] = true;
    }
    if (overlap) conflicts.add('${task.title}：时段重叠 / Time conflict');
  }
  final minutes =
      tasks.fold(0, (sum, t) => sum + (t.endSlot - t.startSlot) * 30);
  if (minutes + plan.totalPlannedMinutes > 1440) {
    conflicts.add('总任务量超过24小时 / Workload exceeds 24 hours');
  }
  return conflicts;
}

void assistantDate(String date) {
  final value = DateTime.tryParse(date);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (value == null ||
      value.toIso8601String().substring(0, 10) != date ||
      value.isBefore(today) ||
      value.isAfter(today.add(const Duration(days: 30)))) {
    throw const FormatException(
        '请选择今天或未来30天的日期 / Choose today or the next 30 days.');
  }
}

int assistantSlot(String text, {bool end = false}) {
  final match = RegExp(r'^(\d{2}):(00|30)$').firstMatch(text);
  if (match == null) {
    throw const FormatException('时间须为整点或半点 / Use HH:00 or HH:30.');
  }
  final slot = int.parse(match[1]!) * 2 + (match[2] == '30' ? 1 : 0);
  if (slot < 0 || slot > (end ? 48 : 47)) {
    throw const FormatException('时间超出当天 / Time outside this day.');
  }
  return slot;
}
