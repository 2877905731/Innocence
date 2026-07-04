import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/auth/domain/models/auth_result.dart';

class AuthApi {
  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> sendLoginCode(String email) async {
    await _apiClient.post(
      'auth/email/send-login-code',
      body: {'email': email},
    );
  }

  Future<void> sendRegisterCode(String email) async {
    await _apiClient.post(
      'auth/email/send-register-code',
      body: {'email': email},
    );
  }

  Future<AuthResult> loginWithPassword({
    required String email,
    required String password,
    required String deviceType,
    required String deviceId,
  }) async {
    final data = await _apiClient.post(
      'auth/login/password',
      body: {
        'email': email,
        'password': password,
        'deviceType': deviceType,
        'deviceId': deviceId,
      },
    );
    return _parseAuthResult(data);
  }

  Future<AuthResult> loginWithCode({
    required String email,
    required String emailCode,
    required String deviceType,
    required String deviceId,
  }) async {
    final data = await _apiClient.post(
      'auth/login/code',
      body: {
        'email': email,
        'emailCode': emailCode,
        'deviceType': deviceType,
        'deviceId': deviceId,
      },
    );
    return _parseAuthResult(data);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String emailCode,
    required String deviceType,
    required String deviceId,
  }) async {
    final data = await _apiClient.post(
      'auth/email/register',
      body: {
        'email': email,
        'password': password,
        'emailCode': emailCode,
        'deviceType': deviceType,
        'deviceId': deviceId,
      },
    );
    return _parseAuthResult(data);
  }

  Future<UserProfile> getProfile(AppSession session) async {
    final data = await _apiClient.get(
      'account/profile',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the current profile.');
    }
    return UserProfile.fromJson(data);
  }

  AuthResult _parseAuthResult(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Auth response is incomplete.');
    }
    return AuthResult.fromJson(data);
  }
}
