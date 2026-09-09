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
}
