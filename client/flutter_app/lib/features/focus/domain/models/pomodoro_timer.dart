/// A device-local timer with its own clock. It never borrows a focus deadline.
class PomodoroTimer {
  const PomodoroTimer(
      {this.id = '',
      this.active = false,
      this.paused = false,
      this.studyMinutes = 25,
      this.breakMinutes = 5,
      this.elapsedMs = 0,
      this.referenceMs = 0,
      this.notices = true});

  final String id;
  final bool active, paused, notices;
  final int studyMinutes, breakMinutes, elapsedMs, referenceMs;
  int get cycleMs => (studyMinutes + breakMinutes) * 60000;
  int get studyMs => studyMinutes * 60000;
  int get positionMs => elapsedMs % cycleMs;
  bool get resting => positionMs >= studyMs && breakMinutes > 0;
  String get stage => resting ? 'break' : 'study';
  int get cycle => elapsedMs ~/ cycleMs + 1;
  int get completed => elapsedMs ~/ cycleMs + (resting ? 1 : 0);
  int get remainingMs => (resting ? cycleMs : studyMs) - positionMs;
  int get remainingSeconds => (remainingMs + 999) ~/ 1000;
  int get deadlineMs => referenceMs + remainingMs;
  String get remainingLabel {
    final seconds = remainingSeconds;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${seconds >= 3600 ? '${two(seconds ~/ 3600)}:' : ''}${two(seconds ~/ 60 % 60)}:${two(seconds % 60)}';
  }

  PomodoroTimer advance(int now) => !active || paused || now <= referenceMs
      ? this
      : copy(elapsedMs: elapsedMs + now - referenceMs, referenceMs: now);

  PomodoroTimer copy(
          {bool? active, bool? paused, int? elapsedMs, int? referenceMs}) =>
      PomodoroTimer(
          id: id,
          active: active ?? this.active,
          paused: paused ?? this.paused,
          studyMinutes: studyMinutes,
          breakMinutes: breakMinutes,
          elapsedMs: elapsedMs ?? this.elapsedMs,
          referenceMs: referenceMs ?? this.referenceMs,
          notices: notices);

  Map<String, dynamic> toJson() => {
        'id': id,
        'active': active,
        'paused': paused,
        'studyMinutes': studyMinutes,
        'breakMinutes': breakMinutes,
        'elapsedMs': elapsedMs,
        'referenceMs': referenceMs,
        'notices': notices
      };

  factory PomodoroTimer.fromJson(Map<String, dynamic> json) {
    final study = json['studyMinutes'], rest = json['breakMinutes'];
    if (json['id'] is! String ||
        json['active'] is! bool ||
        json['paused'] is! bool ||
        json['notices'] is! bool ||
        study is! int ||
        study < 1 ||
        study > 1440 ||
        rest is! int ||
        rest < 0 ||
        rest > 1440 ||
        json['elapsedMs'] is! int ||
        (json['elapsedMs'] as int) < 0 ||
        (json['elapsedMs'] as int) > 3155760000000 ||
        json['referenceMs'] is! int ||
        (json['referenceMs'] as int) < 0 ||
        (json['active'] == true && (json['id'] as String).isEmpty)) {
      throw const FormatException('Invalid pomodoro timer');
    }
    return PomodoroTimer(
        id: json['id'],
        active: json['active'],
        paused: json['paused'],
        studyMinutes: study,
        breakMinutes: rest,
        elapsedMs: json['elapsedMs'],
        referenceMs: json['referenceMs'],
        notices: json['notices']);
  }
}
