/// One day's contribution from one round. Values are cumulative for retries.
class PomodoroStudyRecord {
  const PomodoroStudyRecord(
      {required this.key,
      required this.startMs,
      required this.endMs,
      this.studyMs = 0,
      this.creditedMs = 0,
      this.completedRounds = 0});

  final String key;
  final int startMs, endMs, studyMs, creditedMs, completedRounds;
  String get date => key.substring(key.length - 10);

  PomodoroStudyRecord add(int start, int end, int credit, {int round = 0}) =>
      PomodoroStudyRecord(
          key: key,
          startMs: startMs,
          endMs: end,
          studyMs: studyMs + end - start,
          creditedMs: creditedMs + credit,
          completedRounds: completedRounds + round);

  Map<String, dynamic> toJson() => {
        'recordKey': key,
        'startMs': startMs,
        'endMs': endMs,
        'studyMs': studyMs,
        'creditedMs': creditedMs,
        'completedRounds': completedRounds
      };

  Map<String, dynamic> get request => {
        'recordKey': key,
        'startTime':
            DateTime.fromMillisecondsSinceEpoch(startMs).toIso8601String(),
        'endTime': DateTime.fromMillisecondsSinceEpoch(endMs).toIso8601String(),
        'studySeconds': studyMs ~/ 1000,
        'creditedSeconds': creditedMs ~/ 1000,
        'completedRounds': completedRounds
      };

  factory PomodoroStudyRecord.fromJson(Map<String, dynamic> j) {
    final key = j['recordKey'];
    final start = j['startMs'],
        end = j['endMs'],
        study = j['studyMs'],
        credit = j['creditedMs'],
        rounds = j['completedRounds'];
    if (key is! String ||
        !RegExp(r'^[a-zA-Z0-9_-]+/\d+/\d{4}-\d{2}-\d{2}$').hasMatch(key) ||
        start is! int ||
        start < 0 ||
        end is! int ||
        end < start ||
        study is! int ||
        study < 0 ||
        study > 86400000 ||
        study > end - start ||
        credit is! int ||
        credit < 0 ||
        credit > study ||
        rounds is! int ||
        rounds < 0 ||
        rounds > 1) {
      throw const FormatException('Invalid pomodoro study record');
    }
    return PomodoroStudyRecord(
        key: key,
        startMs: start,
        endMs: end,
        studyMs: study,
        creditedMs: credit,
        completedRounds: rounds);
  }
}
