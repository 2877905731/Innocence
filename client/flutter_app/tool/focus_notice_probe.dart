// Standalone native QA entry point. No auth, HTTP, or business database access.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/platform/focus_notice_bridge.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: FocusNoticeProbe()));
}

class FocusNoticeProbe extends StatefulWidget {
  const FocusNoticeProbe({super.key});

  @override
  State<FocusNoticeProbe> createState() => _FocusNoticeProbeState();
}

class _FocusNoticeProbeState extends State<FocusNoticeProbe>
    with WidgetsBindingObserver {
  final _bridge = FocusNoticeBridge();
  FocusSession _session = FocusSession.empty();
  String _owner = 'local:focusqa';
  String _receipt = '尚未开始';
  String _diagnostics = '';
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _advance());
  }

  void _advance() {
    if (!_session.active || _session.paused) return;
    final next = _session.advanceTo(DateTime.now());
    setState(() => _session = next);
    unawaited(_sync(completed: !next.active));
  }

  Future<void> _sync(
      {bool completed = false, bool clear = false, bool force = false}) async {
    final id = _session.sessionId;
    final owner = _owner;
    final status = await _bridge.sync(
      session: _session,
      owner: clear ? null : owner,
      isChinese: true,
      completed: completed,
      force: force,
    );
    if (!mounted || id != _session.sessionId || owner != _owner) return;
    if (_receipt != status.name || completed) {
      debugPrint('FOCUS_NOTICE_QA status=${status.name} completed=$completed');
      setState(() => _receipt = status.name);
      await _inspect();
    }
  }

  Future<void> _inspect() async {
    final receipt = await const MethodChannel('innocence/focus_notice')
        .invokeMapMethod<String, Object?>('diagnostics');
    debugPrint('FOCUS_NOTICE_QA receipt=$receipt');
    if (mounted) setState(() => _diagnostics = '$receipt');
  }

  Future<void> _start(int seconds) async {
    try {
      await const MethodChannel('innocence/focus_notice')
          .invokeMethod<void>('requestPermission');
    } on PlatformException catch (error) {
      debugPrint('FOCUS_NOTICE_QA permission=${error.code}');
      if (mounted) setState(() => _receipt = 'permission=${error.code}');
      return;
    } on MissingPluginException {
      debugPrint('FOCUS_NOTICE_QA permission=missing_plugin');
      if (mounted) setState(() => _receipt = 'permission=missing_plugin');
      return;
    }
    if (!mounted) return;
    setState(() {
      _session = FocusSession.fromJson({
        'sessionId': DateTime.now().millisecondsSinceEpoch,
        'active': true,
        'paused': false,
        'remainingSeconds': seconds,
        'plannedMinutes': (seconds / 60).ceil(),
      });
    });
    await _sync();
  }

  Future<void> _pauseOrResume() async {
    if (!_session.active) return;
    _advance();
    setState(() {
      _session = FocusSession.fromJson({
        'sessionId': _session.sessionId,
        'active': true,
        'paused': !_session.paused,
        'remainingSeconds': _session.remainingSeconds,
        'elapsedSeconds': _session.elapsedSeconds,
        'plannedMinutes': _session.plannedMinutes,
      });
    });
    await _sync();
  }

  Future<void> _cancel({bool changeOwner = false}) async {
    setState(() {
      _session = FocusSession.empty();
      if (changeOwner) _owner = 'local:other-focusqa';
    });
    await _sync(clear: changeOwner);
  }

  Future<void> _invalidArguments() async {
    try {
      await const MethodChannel('innocence/focus_notice')
          .invokeMethod<String>('sync', {'owner': _owner});
      setState(() => _receipt = 'FAIL: missing fields accepted');
    } on PlatformException catch (error) {
      debugPrint('FOCUS_NOTICE_QA invalid=${error.code}');
      if (mounted) setState(() => _receipt = 'invalid=${error.code}');
    }
  }

  Future<void> _checkSnapshotFallback() async {
    await const MethodChannel('innocence/focus_notice')
        .invokeMethod<void>('qaLiveRightsUnavailable', true);
    await _sync(force: true);
    await _inspect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _advance();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Innocence 通知验证')),
        body: SafeArea(
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('仅使用合成计时，不读取或写入业务资料'),
              const SizedBox(height: 16),
              Text('${_session.remainingSeconds}s',
                  style: const TextStyle(fontSize: 56)),
              Text('paused=${_session.paused} · $_receipt'),
              Text(_diagnostics),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 12, children: [
                FilledButton(
                    onPressed: () => _start(10), child: const Text('10 秒到点')),
                FilledButton(
                    onPressed: () => _start(60), child: const Text('60 秒后台')),
                OutlinedButton(
                    onPressed: _pauseOrResume, child: const Text('暂停 / 继续')),
                OutlinedButton(
                    onPressed: _cancel, child: const Text('提前结束 / 清理')),
                OutlinedButton(
                    onPressed: () => _cancel(changeOwner: true),
                    child: const Text('切换身份')),
                OutlinedButton(
                    onPressed: _invalidArguments, child: const Text('缺字段检查')),
                OutlinedButton(
                    onPressed: _checkSnapshotFallback,
                    child: const Text('普通通知降级检查')),
                OutlinedButton(onPressed: _inspect, child: const Text('原生回执')),
                OutlinedButton(
                    onPressed: () => _sync(force: true),
                    child: const Text('重读空计时')),
              ]),
            ]),
          ),
        ),
      );
}
