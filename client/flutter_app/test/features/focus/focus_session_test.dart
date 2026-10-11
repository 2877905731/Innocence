import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

void main() {
  test('paused focus snapshot does not advance locally', () {
    final paused = FocusSession.fromJson({
      'sessionId': 7,
      'active': true,
      'paused': true,
      'taskName': 'Read',
      'stageName': 'paused',
      'plannedMinutes': 25,
      'elapsedSeconds': 120,
      'remainingSeconds': 1380,
      'stageRemainingSeconds': 1380,
    });

    final next = paused.tick();

    expect(next, same(paused));
    expect(next.elapsedSeconds, 120);
    expect(next.remainingSeconds, 1380);
  });

  test('active focus snapshot still advances one second', () {
    final active = FocusSession.fromJson({
      'sessionId': 8,
      'active': true,
      'paused': false,
      'taskName': 'Write',
      'stageName': 'study',
      'plannedMinutes': 25,
      'elapsedSeconds': 120,
      'remainingSeconds': 1380,
      'stageRemainingSeconds': 1380,
    });

    final next = active.tick();

    expect(next.elapsedSeconds, 121);
    expect(next.remainingSeconds, 1379);
    expect(next.paused, isFalse);
  });

  test('background suspension catches up and completes at the deadline', () {
    final focus = FocusSession.fromJson({
      'sessionId': 9,
      'active': true,
      'stageName': 'study',
      'elapsedSeconds': 60,
      'remainingSeconds': 120,
    });
    final afterBackground =
        focus.advanceTo(focus.referenceTime.add(const Duration(seconds: 90)));
    expect(afterBackground.elapsedSeconds, 150);
    expect(afterBackground.remainingSeconds, 30);
    final done = afterBackground
        .advanceTo(focus.referenceTime.add(const Duration(minutes: 10)));
    expect(done.active, isFalse);
    expect(done.elapsedSeconds, 180);
    expect(done.remainingSeconds, 0);
    expect(done.stageName, 'finished');
  });

  test('subsecond callbacks preserve deadline and paused time is excluded', () {
    final focus =
        FocusSession.fromJson({'active': true, 'remainingSeconds': 100});
    expect(
        focus.advanceTo(
            focus.referenceTime.add(const Duration(milliseconds: 900))),
        same(focus));
    final next = focus
        .advanceTo(focus.referenceTime.add(const Duration(milliseconds: 1900)));
    expect(next.remainingSeconds, 99);
    expect(next.referenceTime.add(Duration(seconds: next.remainingSeconds)),
        focus.referenceTime.add(Duration(seconds: focus.remainingSeconds)));
    final paused = FocusSession.fromJson(
        {'active': true, 'paused': true, 'remainingSeconds': 100});
    expect(paused.advanceTo(paused.referenceTime.add(const Duration(hours: 1))),
        same(paused));
  });

  test('background catch-up resolves pomodoro break and next cycle', () {
    final focus = FocusSession.fromJson({
      'active': true,
      'remainingSeconds': 3600,
      'bindPomodoro': true,
      'pomodoroStudyMinutes': 25,
      'pomodoroBreakMinutes': 5,
    });
    final duringBreak =
        focus.advanceTo(focus.referenceTime.add(const Duration(minutes: 27)));
    expect(duringBreak.stageName, 'break');
    expect(duringBreak.stageRemainingSeconds, 180);
    final nextCycle =
        focus.advanceTo(focus.referenceTime.add(const Duration(minutes: 31)));
    expect(nextCycle.stageName, 'study');
    expect(nextCycle.currentCycleNo, 2);
    expect(nextCycle.completedPomodoroCount, 1);
  });
}
