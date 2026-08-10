import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/settings/data/settings_api.dart';

void main() {
  const session = AppSession(
    accessToken: 'synthetic-token',
    tokenType: 'Bearer',
    userId: 7,
    deviceType: 'windows',
    deviceSlot: 'desktop',
    deviceId: 'synthetic-desktop',
  );

  test('avatar upload rejects an empty file before opening the network', () async {
    final api = SettingsApi();

    await expectLater(
      api.uploadAvatar(session, bytes: const [], filename: 'avatar.png'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '请选择头像文件。',
        ),
      ),
    );
  });

  test('avatar upload rejects unsupported extensions', () async {
    final api = SettingsApi();

    await expectLater(
      api.uploadAvatar(session, bytes: const [1], filename: 'avatar.gif'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '头像仅支持 JPEG 或 PNG 图片。',
        ),
      ),
    );
  });

  test('avatar upload rejects files over five MiB', () async {
    final api = SettingsApi();

    await expectLater(
      api.uploadAvatar(
        session,
        bytes: List<int>.filled(5 * 1024 * 1024 + 1, 0),
        filename: 'avatar.png',
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '头像文件不能超过 5 MiB。',
        ),
      ),
    );
  });
}
