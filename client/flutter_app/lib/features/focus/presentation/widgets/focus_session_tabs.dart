import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/features/focus/domain/models/focus_session.dart';

typedef ConfigureFocusPomodoro = Future<void> Function({
  required bool bindPomodoro,
  required int pomodoroStudyMinutes,
  required int pomodoroBreakMinutes,
});

class FocusSessionTabs extends StatefulWidget {
  const FocusSessionTabs(
      {super.key,
      required this.session,
      required this.isChinese,
      required this.isBusy,
      required this.timer,
      this.onConfigure});
  final FocusSession session;
  final bool isChinese;
  final bool isBusy;
  final Widget timer;
  final ConfigureFocusPomodoro? onConfigure;

  @override
  State<FocusSessionTabs> createState() => _FocusSessionTabsState();
}

class _FocusSessionTabsState extends State<FocusSessionTabs> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _study;
  late final TextEditingController _rest;
  int _tab = 0;
  bool _saving = false;
  String text(String zh, String en) => widget.isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _study = TextEditingController();
    _rest = TextEditingController();
    _load();
  }

  void _load() {
    _study.text =
        '${widget.session.bindPomodoro ? widget.session.pomodoroStudyMinutes : 25}';
    _rest.text =
        '${widget.session.bindPomodoro ? widget.session.pomodoroBreakMinutes : 5}';
  }

  @override
  void didUpdateWidget(FocusSessionTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.sessionId != widget.session.sessionId ||
        oldWidget.session.bindPomodoro != widget.session.bindPomodoro ||
        oldWidget.session.pomodoroStudyMinutes !=
            widget.session.pomodoroStudyMinutes ||
        oldWidget.session.pomodoroBreakMinutes !=
            widget.session.pomodoroBreakMinutes) {
      _load();
    }
  }

  @override
  void dispose() {
    _study.dispose();
    _rest.dispose();
    super.dispose();
  }

  Future<void> _save(bool bind) async {
    if (bind && !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onConfigure!(
          bindPomodoro: bind,
          pomodoroStudyMinutes: bind ? int.parse(_study.text) : 0,
          pomodoroBreakMinutes: bind ? int.parse(_rest.text) : 0);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _minutes(TextEditingController controller, bool study) =>
      TextFormField(
        key: ValueKey(
            study ? 'pomodoro-study-minutes' : 'pomodoro-break-minutes'),
        controller: controller,
        enabled: !_saving && !widget.isBusy,
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
        validator: (value) {
          final minutes = int.tryParse(value ?? '');
          return minutes == null || minutes < (study ? 1 : 0) || minutes > 1440
              ? text('请输入范围内的整数', 'Enter a whole number in range')
              : null;
        },
      );

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final enabled = session.active &&
        !widget.isBusy &&
        !_saving &&
        widget.onConfigure != null;
    final stage = session.stageName == 'break'
        ? text('休息', 'Break')
        : text('学习', 'Study');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 12, runSpacing: 8, children: [
        ChoiceChip(
            key: const ValueKey('focus-timer-tab'),
            label: Text(text('专注计时', 'Focus timer')),
            selected: _tab == 0,
            onSelected: (_) => setState(() => _tab = 0)),
        ChoiceChip(
            key: const ValueKey('focus-pomodoro-tab'),
            label: Text(text('番茄闹钟', 'Pomodoro')),
            selected: _tab == 1,
            onSelected: (_) => setState(() => _tab = 1)),
      ]),
      const SizedBox(height: 16),
      if (_tab == 0)
        widget.timer
      else
        GlassPanel(
            child: Form(
                key: _form,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(text('番茄闹钟', 'Pomodoro'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if (session.active && session.bindPomodoro) ...[
                        Text(
                            session.paused
                                ? text('$stage · 已暂停', '$stage · Paused')
                                : stage,
                            key: const ValueKey('pomodoro-stage'),
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(session.stageRemainingLabel,
                            key: const ValueKey('pomodoro-stage-time'),
                            style: Theme.of(context).textTheme.displaySmall),
                        Text(text(
                            '第 ${session.currentCycleNo} 轮 · 已完成 ${session.completedPomodoroCount} 次',
                            'Cycle ${session.currentCycleNo} · ${session.completedPomodoroCount} completed')),
                        const SizedBox(height: 16),
                      ] else
                        Text(session.active
                            ? text('尚未绑定番茄闹钟', 'Pomodoro is not bound')
                            : text('先开始专注，再绑定番茄闹钟。',
                                'Start focus to bind a pomodoro timer.')),
                      const SizedBox(height: 16),
                      LayoutBuilder(builder: (context, constraints) {
                        final study = _minutes(_study, true),
                            rest = _minutes(_rest, false);
                        return constraints.maxWidth < 460
                            ? Column(children: [
                                study,
                                const SizedBox(height: 16),
                                rest
                              ])
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Expanded(child: study),
                                    const SizedBox(width: 20),
                                    Expanded(child: rest)
                                  ]);
                      }),
                      const SizedBox(height: 16),
                      Text(text('保存新时长后，从学习阶段重新开始；总专注时间和已完成次数保留。休息设为 0 可连续学习。',
                          'New durations start a study stage. Focus time and completed pomodoros are kept. Use 0 break minutes for continuous study.')),
                      const SizedBox(height: 16),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        FilledButton.icon(
                            key: const ValueKey('pomodoro-save'),
                            onPressed: enabled ? () => _save(true) : null,
                            icon: const Icon(Icons.timer_outlined),
                            label: Text(session.bindPomodoro
                                ? text('保存设置', 'Save settings')
                                : text('绑定番茄闹钟', 'Bind pomodoro'))),
                        if (session.bindPomodoro)
                          OutlinedButton(
                              key: const ValueKey('pomodoro-unbind'),
                              onPressed: enabled ? () => _save(false) : null,
                              child: Text(text('解除绑定', 'Unbind'))),
                      ]),
                    ]))),
    ]);
  }
}
