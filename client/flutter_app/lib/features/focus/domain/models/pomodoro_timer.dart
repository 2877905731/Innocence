import 'pomodoro_study_record.dart';

/// A single, bounded stage. Completion always waits for an explicit next start.
class PomodoroTimer {
  const PomodoroTimer(
      {this.id = '',
      this.active = false,
      this.paused = false,
      this.studyMinutes = 25,
      this.breakMinutes = 5,
      this.elapsedMs = 0,
      this.referenceMs = 0,
      this.notices = true,
      this.stage = 'study',
      this.cycle = 1,
      this.completed = 0,
      this.awaitingNext = false,
      this.records = const [],
      this.coveredFromMs = 0,
      this.coveredUntilMs = 0,
      this.boundSessionId = 0,
      this.boundUntilMs = 0});

  final String id, stage;
  final bool active, paused, notices, awaitingNext;
  final int studyMinutes,
      breakMinutes,
      elapsedMs,
      referenceMs,
      cycle,
      completed;
  final List<PomodoroStudyRecord> records;
  final int coveredFromMs, coveredUntilMs;
  final int boundSessionId, boundUntilMs;
  bool get bound => boundSessionId > 0;
  int get studyMs => studyMinutes * 60000;
  int get cycleMs => (studyMinutes + breakMinutes) * 60000;
  bool get resting => stage == 'break';
  int get stageMs => (resting ? breakMinutes : studyMinutes) * 60000;
  int get remainingMs => (stageMs - elapsedMs).clamp(0, stageMs);
  int get remainingSeconds => (remainingMs + 999) ~/ 1000;
  int get deadlineMs => referenceMs + remainingMs;
  bool get running => active && !paused && !awaitingNext;
  String get remainingLabel {
    final seconds = remainingSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${seconds >= 3600 ? '${two(seconds ~/ 3600)}:' : ''}${two(seconds ~/ 60 % 60)}:${two(seconds % 60)}';
  }

  PomodoroTimer advance(int now,
      {int Function(int start, int end)? coveredMs}) {
    final expired = bound && !paused && now >= boundUntilMs;
    if (expired && !running) return copy(active: false);
    if (bound && now > boundUntilMs) now = boundUntilMs;
    if (!running || now <= referenceMs) {
      return expired ? copy(active: false) : this;
    }
    final consumed = (now - referenceMs).clamp(0, remainingMs);
    final end = referenceMs + consumed;
    final ledger = [...records];
    if (!resting) {
      var cursor = referenceMs;
      while (cursor < end) {
        final date = DateTime.fromMillisecondsSinceEpoch(cursor);
        final midnight = DateTime(date.year, date.month, date.day + 1)
            .millisecondsSinceEpoch;
        final until = end < midnight ? end : midnight;
        final overlapStart = cursor > coveredFromMs ? cursor : coveredFromMs;
        final overlapEnd = until < coveredUntilMs ? until : coveredUntilMs;
        final overlap = (overlapEnd - overlapStart).clamp(0, until - cursor);
        final credit = (until -
                cursor -
                (bound ? 0 : (coveredMs?.call(cursor, until) ?? overlap)))
            .clamp(0, until - cursor);
        _append(ledger, cursor, until, credit);
        cursor = until;
      }
    }
    final done = consumed == remainingMs;
    final roundDone = done && (resting || breakMinutes == 0);
    if (roundDone) _append(ledger, end, end, 0, round: 1);
    return copy(
        active: expired ? false : null,
        elapsedMs: elapsedMs + consumed,
        referenceMs: end,
        awaitingNext: done,
        completed: completed + (roundDone ? 1 : 0),
        records: ledger);
  }

  void _append(List<PomodoroStudyRecord> ledger, int start, int end, int credit,
      {int round = 0}) {
    final date = DateTime.fromMillisecondsSinceEpoch(start);
    final day =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final key = '$id/$cycle/$day';
    final index = ledger.indexWhere((r) => r.key == key);
    final row = index < 0
        ? PomodoroStudyRecord(key: key, startMs: start, endMs: start)
        : ledger[index];
    final next = row.add(start, end, credit, round: round);
    if (index < 0) {
      ledger.add(next);
    } else {
      ledger[index] = next;
    }
  }

  PomodoroTimer beginNextStage(int now) {
    if (!active || !awaitingNext) return this;
    final nextStudy = resting || breakMinutes == 0;
    return copy(
        stage: nextStudy ? 'study' : 'break',
        elapsedMs: 0,
        referenceMs: now,
        awaitingNext: false,
        paused: false,
        cycle: cycle + (nextStudy ? 1 : 0),
        records: nextStudy ? [] : records);
  }

  PomodoroTimer copy(
          {bool? active,
          bool? paused,
          int? elapsedMs,
          int? referenceMs,
          String? stage,
          int? cycle,
          int? completed,
          bool? awaitingNext,
          List<PomodoroStudyRecord>? records,
          int? coveredFromMs,
          int? coveredUntilMs,
          int? boundUntilMs}) =>
      PomodoroTimer(
          id: id,
          active: active ?? this.active,
          paused: paused ?? this.paused,
          studyMinutes: studyMinutes,
          breakMinutes: breakMinutes,
          elapsedMs: elapsedMs ?? this.elapsedMs,
          referenceMs: referenceMs ?? this.referenceMs,
          notices: notices,
          stage: stage ?? this.stage,
          cycle: cycle ?? this.cycle,
          completed: completed ?? this.completed,
          awaitingNext: awaitingNext ?? this.awaitingNext,
          records: records ?? this.records,
          coveredFromMs: coveredFromMs ?? this.coveredFromMs,
          coveredUntilMs: coveredUntilMs ?? this.coveredUntilMs,
          boundSessionId: boundSessionId,
          boundUntilMs: boundUntilMs ?? this.boundUntilMs);

  Map<String, dynamic> toJson() => {
        'version': 2,
        'id': id,
        'active': active,
        'paused': paused,
        'studyMinutes': studyMinutes,
        'breakMinutes': breakMinutes,
        'elapsedMs': elapsedMs,
        'referenceMs': referenceMs,
        'notices': notices,
        'stage': stage,
        'cycle': cycle,
        'completed': completed,
        'awaitingNext': awaitingNext,
        'records': records.map((r) => r.toJson()).toList(),
        'coveredFromMs': coveredFromMs,
        'coveredUntilMs': coveredUntilMs,
        'boundSessionId': boundSessionId,
        'boundUntilMs': boundUntilMs
      };

  factory PomodoroTimer.fromJson(Map<String, dynamic> j) {
    final study = j['studyMinutes'],
        rest = j['breakMinutes'],
        elapsed = j['elapsedMs'];
    if (j['id'] is! String ||
        j['active'] is! bool ||
        j['paused'] is! bool ||
        j['notices'] is! bool ||
        study is! int ||
        study < 1 ||
        study > 1440 ||
        rest is! int ||
        rest < 0 ||
        rest > 1440 ||
        elapsed is! int ||
        elapsed < 0 ||
        elapsed > 3155760000000 ||
        j['referenceMs'] is! int ||
        j['referenceMs'] < 0 ||
        (j['active'] == true &&
            !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(j['id']))) {
      throw const FormatException('Invalid pomodoro timer');
    }
    final legacy = !j.containsKey('version');
    final period = (study + rest) * 60000;
    final resting = elapsed % period >= study * 60000 && rest > 0;
    final stage = legacy ? (resting ? 'break' : 'study') : j['stage'];
    final progress =
        legacy ? elapsed % period - (resting ? study * 60000 : 0) : elapsed;
    final cycle = legacy ? elapsed ~/ period + 1 : j['cycle'];
    final completed = legacy ? elapsed ~/ period : j['completed'];
    final awaiting = legacy ? false : j['awaitingNext'];
    if ((!legacy && j['version'] != 2) ||
        (stage != 'study' && stage != 'break') ||
        (stage == 'break' && rest == 0) ||
        cycle is! int ||
        cycle < 1 ||
        completed is! int ||
        completed < 0 ||
        completed > cycle ||
        awaiting is! bool ||
        progress > (stage == 'study' ? study : rest) * 60000 ||
        (awaiting && progress != (stage == 'study' ? study : rest) * 60000) ||
        (!legacy && j['records'] is! List)) {
      throw const FormatException('Invalid pomodoro stage');
    }
    final from = j['coveredFromMs'] ?? 0, until = j['coveredUntilMs'] ?? 0;
    if (from is! int || until is! int || from < 0 || until < from) {
      throw const FormatException('Invalid focus coverage');
    }
    final boundId = j['boundSessionId'] ?? 0, boundEnd = j['boundUntilMs'] ?? 0;
    if (boundId is! int ||
        boundEnd is! int ||
        boundId < 0 ||
        boundEnd < 0 ||
        (boundId > 0 && boundEnd == 0)) {
      throw const FormatException('Invalid focus binding');
    }
    return PomodoroTimer(
        id: j['id'],
        active: j['active'],
        paused: j['paused'],
        studyMinutes: study,
        breakMinutes: rest,
        elapsedMs: progress,
        referenceMs: j['referenceMs'],
        notices: j['notices'],
        stage: stage,
        cycle: cycle,
        completed: completed,
        awaitingNext: awaiting,
        coveredFromMs: from,
        coveredUntilMs: until,
        boundSessionId: boundId,
        boundUntilMs: boundEnd,
        records: legacy
            ? []
            : (j['records'] as List)
                .map((r) => PomodoroStudyRecord.fromJson(
                    Map<String, dynamic>.from(r as Map)))
                .toList());
  }
}
