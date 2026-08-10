import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/features/account/domain/models/blacklist_item.dart';
import 'package:innocence_flutter/features/account/domain/models/current_device_session.dart';

void main() {
  test('blacklist item keeps the blocked user id and creation time', () {
    final item = BlacklistItem.fromJson(const {
      'blockedUserId': '42',
      'createTime': '2026-08-10T09:30:00',
    });

    expect(item.blockedUserId, 42);
    expect(item.createTime, '2026-08-10T09:30:00');
  });

  test('current device session parses numeric flags without exposing token data', () {
    final session = CurrentDeviceSession.fromJson(const {
      'deviceType': 'windows',
      'deviceSlot': 'desktop',
      'deviceId': 'desktop-test-device',
      'online': 1,
      'replaced': 0,
      'loginTime': '2026-08-10T09:30:00',
      'logoutTime': '',
    });

    expect(session.deviceType, 'windows');
    expect(session.online, isTrue);
    expect(session.replaced, isFalse);
    expect(session.loginTime, '2026-08-10T09:30:00');
  });

  test('missing session fields degrade to safe empty values', () {
    final session = CurrentDeviceSession.fromJson(const {});

    expect(session.deviceType, isEmpty);
    expect(session.deviceId, isEmpty);
    expect(session.online, isFalse);
    expect(session.replaced, isFalse);
  });
}
