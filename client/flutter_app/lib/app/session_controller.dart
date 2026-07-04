import 'package:flutter/foundation.dart';
import 'package:innocence_flutter/core/config/app_config.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/auth/data/auth_api.dart';
import 'package:innocence_flutter/features/auth/data/auth_local_storage.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/auth/domain/models/auth_result.dart';
import 'package:innocence_flutter/features/plans/data/study_plan_api.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

enum SessionStatus {
  initializing,
  unauthenticated,
  authenticated,
}

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthApi authApi,
    required AuthLocalStorage localStorage,
    StudyPlanApi? studyPlanApi,
  })  : _authApi = authApi,
        _localStorage = localStorage,
        _studyPlanApi = studyPlanApi ?? StudyPlanApi();

  final AuthApi _authApi;
  final AuthLocalStorage _localStorage;
  final StudyPlanApi _studyPlanApi;

  SessionStatus _status = SessionStatus.initializing;
  AppSession? _session;
  UserProfile? _profile;
  TodayPlan _todayPlan = TodayPlan.empty();
  bool _isBusy = false;
  bool _didInitialize = false;
  String? _bannerMessage;

  SessionStatus get status => _status;
  AppSession? get session => _session;
  UserProfile? get profile => _profile;
  TodayPlan get todayPlan => _todayPlan;
  bool get isBusy => _isBusy;
  String? get bannerMessage => _bannerMessage;

  Future<void> initialize() async {
    if (_didInitialize) {
      return;
    }
    _didInitialize = true;

    final savedSession = _localStorage.readSession();
    if (savedSession == null) {
      _status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _status = SessionStatus.initializing;
    notifyListeners();

    try {
      final profile = await _authApi.getProfile(savedSession);
      final todayPlan = await _studyPlanApi.getTodayPlan(savedSession);
      _session = savedSession;
      _profile = profile;
      _todayPlan = todayPlan;
      _bannerMessage = null;
      _status = SessionStatus.authenticated;
    } on ApiException {
      await _localStorage.clearSession();
      _session = null;
      _profile = null;
      _todayPlan = TodayPlan.empty();
      _bannerMessage = 'Session expired. Please sign in again.';
      _status = SessionStatus.unauthenticated;
    } catch (_) {
      await _localStorage.clearSession();
      _session = null;
      _profile = null;
      _todayPlan = TodayPlan.empty();
      _bannerMessage = 'Failed to restore the previous session.';
      _status = SessionStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.loginWithPassword(
        email: email,
        password: password,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> loginWithCode({
    required String email,
    required String emailCode,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.loginWithCode(
        email: email,
        emailCode: emailCode,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    await _runBusyAction(() async {
      final deviceType = AppConfig.deviceType;
      final deviceId = await _localStorage.readOrCreateDeviceId(deviceType);
      final result = await _authApi.register(
        email: email,
        password: password,
        emailCode: emailCode,
        deviceType: deviceType,
        deviceId: deviceId,
      );
      await _completeAuthentication(result);
    });
  }

  Future<void> sendLoginCode(String email) {
    return _authApi.sendLoginCode(email);
  }

  Future<void> sendRegisterCode(String email) {
    return _authApi.sendRegisterCode(email);
  }

  Future<void> refreshProfile() async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final profile = await _authApi.getProfile(currentSession);
      final todayPlan = await _studyPlanApi.getTodayPlan(currentSession);
      _profile = profile;
      _todayPlan = todayPlan;
      _bannerMessage = null;
    }, fallbackMessage: 'Failed to refresh the profile.');
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();
    try {
      await _localStorage.clearSession();
      _session = null;
      _profile = null;
      _todayPlan = TodayPlan.empty();
      _bannerMessage = null;
      _status = SessionStatus.unauthenticated;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void clearBanner() {
    if (_bannerMessage == null) {
      return;
    }
    _bannerMessage = null;
    notifyListeners();
  }

  Future<void> saveTodayPlan(TodayPlan plan) async {
    final currentSession = _session;
    if (currentSession == null) {
      return;
    }

    await _runBusyAction(() async {
      final savedPlan = await _studyPlanApi.saveTodayPlan(currentSession, plan);
      _todayPlan = savedPlan;
      _bannerMessage = null;
    }, fallbackMessage: 'Failed to save the today plan.');
  }

  Future<void> toggleTodayPlanItem(int index, bool completed) async {
    if (index < 0 || index >= _todayPlan.items.length) {
      return;
    }
    final updatedPlan = _todayPlan.toggleAt(index, completed);
    await saveTodayPlan(updatedPlan);
  }

  Future<void> _completeAuthentication(AuthResult result) async {
    await _localStorage.saveSession(result.session);
    try {
      final profile = await _authApi.getProfile(result.session);
      final todayPlan = await _studyPlanApi.getTodayPlan(result.session);
      _session = result.session;
      _profile = profile;
      _todayPlan = todayPlan;
      _bannerMessage = null;
      _status = SessionStatus.authenticated;
    } catch (_) {
      await _localStorage.clearSession();
      _session = null;
      _profile = null;
      _todayPlan = TodayPlan.empty();
      _status = SessionStatus.unauthenticated;
      rethrow;
    }
  }

  Future<void> _runBusyAction(
    Future<void> Function() action, {
    String fallbackMessage = 'Operation failed. Please try again.',
  }) async {
    _isBusy = true;
    notifyListeners();

    try {
      await action();
    } on ApiException catch (error) {
      _bannerMessage = error.message;
    } catch (_) {
      _bannerMessage = fallbackMessage;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
