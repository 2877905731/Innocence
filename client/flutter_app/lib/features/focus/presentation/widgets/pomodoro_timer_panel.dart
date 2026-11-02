import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import '../../application/pomodoro_controller.dart';

class PomodoroTimerPanel extends StatefulWidget {
  const PomodoroTimerPanel(
      {super.key, required this.controller, required this.isChinese});
  final PomodoroController controller;
  final bool isChinese;
  @override
  State<PomodoroTimerPanel> createState() => _PomodoroTimerPanelState();
}

class _PomodoroTimerPanelState extends State<PomodoroTimerPanel> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _study, _rest;
  late bool _notices;
  String? _seenId;
  String text(String zh, String en) => widget.isChinese ? zh : en;
  @override
  void initState() {
    super.initState();
    _study =
        TextEditingController(text: '${widget.controller.timer.studyMinutes}');
    _rest =
        TextEditingController(text: '${widget.controller.timer.breakMinutes}');
    _notices = widget.controller.timer.notices;
    _seenId = widget.controller.timer.id;
  }

  @override
  void dispose() {
    _study.dispose();
    _rest.dispose();
    super.dispose();
  }

  Widget _minutes(TextEditingController controller, bool study, bool enabled) =>
      TextFormField(
          key: ValueKey(study
              ? 'independent-study-minutes'
              : 'independent-break-minutes'),
          controller: controller,
          onChanged: (_) => setState(() {}),
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4)
          ],
          decoration: InputDecoration(
              labelText: study
                  ? text('学习时长（分钟）', 'Study minutes')
                  : text('休息时长（分钟）', 'Break minutes'),
              helperText: study ? '1–1440' : '0–1440'),
          validator: (s) {
            final n = int.tryParse(s ?? '');
            return n == null || n < (study ? 1 : 0) || n > 1440
                ? text('请输入范围内的整数', 'Enter a whole number in range')
                : null;
          });
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final c = widget.controller, t = c.timer;
        if (_seenId != t.id) {
          _seenId = t.id;
          _study.text = '${t.studyMinutes}';
          _rest.text = '${t.breakMinutes}';
          _notices = t.notices;
        }
        final editable = !c.busy && !t.active;
        return GlassPanel(
            child: Form(
                key: _form,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(text('独立番茄闹钟', 'Independent pomodoro'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                          t.active
                              ? t.awaitingNext
                                  ? (t.resting
                                      ? text('休息完成 · 本轮已完成',
                                          'Break complete · Round complete')
                                      : text('学习完成 · 等待下一阶段',
                                          'Study complete · Ready for the next stage'))
                                  : '${t.resting ? text('休息', 'Break') : text('学习', 'Study')}${t.paused ? text(' · 已暂停', ' · Paused') : ''}'
                              : text(
                                  t.id.isEmpty ? '准备开始' : '本次已结束',
                                  t.id.isEmpty
                                      ? 'Ready to start'
                                      : 'Session ended'),
                          key: const ValueKey('independent-pomodoro-stage')),
                      Text(
                          t.active
                              ? t.remainingLabel
                              : '${_study.text.padLeft(2, '0')}:00',
                          key: const ValueKey('independent-pomodoro-time'),
                          style: Theme.of(context).textTheme.displaySmall),
                      Text(text('第 ${t.cycle} 轮 · 已完成 ${t.completed} 次',
                          'Cycle ${t.cycle} · ${t.completed} completed')),
                      const SizedBox(height: 16),
                      Text(text('学习到点即停并提醒，点击后才开始休息；休息完成后提醒，手动开始下一轮。',
                          'Study stops and alerts at the deadline. Start the break when ready, then start the next round after the break alert.')),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                          builder: (context, size) => size.maxWidth < 460
                              ? Column(children: [
                                  _minutes(_study, true, editable),
                                  const SizedBox(height: 16),
                                  _minutes(_rest, false, editable)
                                ])
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Expanded(
                                          child:
                                              _minutes(_study, true, editable)),
                                      const SizedBox(width: 20),
                                      Expanded(
                                          child:
                                              _minutes(_rest, false, editable))
                                    ])),
                      Material(
                          color: Colors.transparent,
                          child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(text('系统通知', 'System notifications')),
                              subtitle: Text(text('显示阶段倒计时与到点提醒',
                                  'Show the stage countdown and alerts')),
                              value: _notices,
                              onChanged: editable
                                  ? (v) => setState(() => _notices = v)
                                  : null)),
                      Text(text(
                          '学习计入学习时间，休息、暂停和等待不计入。与专注同时运行时只记一次。休息设为 0 时仍需手动开始下一轮。',
                          'Study counts toward learning time. Breaks, pauses and waiting do not. Overlapping focus time counts once. A zero-minute break still waits for the next start.')),
                      if (c.error != null) ...[
                        const SizedBox(height: 12),
                        TextButton(
                            onPressed: c.busy ? null : c.retryRecords,
                            child: Text(text('重试同步', 'Retry sync'))),
                        TextButton(
                            onPressed: c.busy ? null : c.retryRestore,
                            child: Text(text('重试恢复', 'Retry restore'))),
                        Text(c.error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))
                      ],
                      if (t.active &&
                          t.notices &&
                          c.noticeStatus != 'available') ...[
                        const SizedBox(height: 12),
                        Text(c.noticeStatus == 'permissionRequired'
                            ? text('系统通知未授权，计时仍会继续。',
                                'Notifications are disabled. The timer continues.')
                            : c.noticeStatus == 'exactPermissionRequired'
                                ? text('精确闹钟未授权，后台提醒可能延迟。',
                                    'Allow exact alarms for timely background alerts.')
                                : text('系统动态倒计时或后台提醒不可用；请保持应用在前台查看当前阶段。',
                                    'Live countdown or background alerts are unavailable. Keep the app in the foreground.')),
                        TextButton(
                            onPressed: c.openSettings,
                            child: Text(text('通知设置', 'Notification settings'))),
                      ],
                      const SizedBox(height: 16),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        if (!t.active)
                          FilledButton.icon(
                              key: const ValueKey('independent-pomodoro-start'),
                              onPressed: c.busy
                                  ? null
                                  : () async {
                                      if (_form.currentState!.validate()) {
                                        await c.start(int.parse(_study.text),
                                            int.parse(_rest.text), _notices);
                                      }
                                    },
                              icon: const Icon(Icons.play_arrow),
                              label: Text(text('开始番茄闹钟', 'Start pomodoro')))
                        else ...[
                          if (t.awaitingNext)
                            FilledButton.icon(
                                key:
                                    const ValueKey('independent-pomodoro-next'),
                                onPressed: c.busy ? null : c.startNextStage,
                                icon: const Icon(Icons.play_arrow),
                                label: Text(!t.resting && t.breakMinutes > 0
                                    ? text('开始休息', 'Start break')
                                    : text(
                                        '开始下一轮学习', 'Start next study round')))
                          else
                            FilledButton.icon(
                                key: const ValueKey(
                                    'independent-pomodoro-pause'),
                                onPressed: c.busy ? null : c.togglePause,
                                icon: Icon(
                                    t.paused ? Icons.play_arrow : Icons.pause),
                                label: Text(t.paused
                                    ? text('继续', 'Resume')
                                    : text('暂停', 'Pause'))),
                          OutlinedButton(
                              key:
                                  const ValueKey('independent-pomodoro-finish'),
                              onPressed: c.busy ? null : c.finish,
                              child: Text(text('结束番茄闹钟', 'End pomodoro'))),
                        ],
                      ]),
                    ])));
      });
}
