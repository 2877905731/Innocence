import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import '../../domain/models/focus_session.dart';

class StartFocusSessionDialog extends StatefulWidget {
  const StartFocusSessionDialog({super.key});

  @override
  State<StartFocusSessionDialog> createState() =>
      _StartFocusSessionDialogState();
}

class _StartFocusSessionDialogState extends State<StartFocusSessionDialog> {
  late final TextEditingController _taskNameController;
  late final TextEditingController _durationController;
  int get _durationMinutes => int.tryParse(_durationController.text) ?? 0;
  String? _validationMessage;

  String _text(String zh, String en) {
    return localizedText(context, zh, en);
  }

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController();
    _durationController = TextEditingController(text: '60');
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_durationMinutes < 1 || _durationMinutes > 1440) {
      setState(() {
        _validationMessage = _text('请输入 1–1440 分钟的专注时长。',
            'Enter a focus duration from 1 to 1440 minutes.');
      });
      return;
    }
    final draft = FocusSessionDraft(
      taskName: _taskNameController.text.trim(),
      endTime: DateTime.now().add(Duration(minutes: _durationMinutes)),
      bindPomodoro: false,
      pomodoroStudyMinutes: 0,
      pomodoroBreakMinutes: 0,
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final plannedEndTime =
        DateTime.now().add(Duration(minutes: _durationMinutes));
    final endHour = plannedEndTime.hour.toString().padLeft(2, '0');
    final endMinute = plannedEndTime.minute.toString().padLeft(2, '0');

    return AlertDialog(
      title: Text(_text('开始专注', 'Start focus session')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelText: _text('任务名称', 'Task name'),
                  hintText: _text('例如：英语阅读', 'For example: English reading'),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _text('你想学习多久？', 'How long do you want to study?'),
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [30, 45, 60, 90, 120].map((minutes) {
                  final selected = _durationMinutes == minutes;
                  return ChoiceChip(
                    label: Text(_text('$minutes 分钟', '$minutes min')),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _durationController.text = '$minutes';
                        _validationMessage = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('custom-focus-minutes'),
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4)
                ],
                decoration: InputDecoration(
                  labelText:
                      _text('自定义专注时长（分钟）', 'Custom focus duration (minutes)'),
                  helperText: '1–1440',
                ),
                onChanged: (_) => setState(() => _validationMessage = null),
              ),
              const SizedBox(height: 12),
              Text(
                _text(
                  '结束于 $endHour:$endMinute  |  计划 ${FocusSession.formatMinutes(_durationMinutes)}',
                  'Ends at $endHour:$endMinute  |  Planned ${FocusSession.formatMinutes(_durationMinutes)}',
                ),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Text(_text('到点结束并提醒。番茄学习与休息可在番茄分页分别开始。',
                  'Stops and alerts at the deadline. Start study and break stages in the pomodoro tab.')),
              if (_validationMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _validationMessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade200,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_text('取消', 'Cancel')),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_text('开始', 'Start')),
        ),
      ],
    );
  }
}

class FocusSessionDraft {
  const FocusSessionDraft({
    required this.taskName,
    required this.endTime,
    required this.bindPomodoro,
    required this.pomodoroStudyMinutes,
    required this.pomodoroBreakMinutes,
  });

  final String taskName;
  final DateTime endTime;
  final bool bindPomodoro;
  final int pomodoroStudyMinutes;
  final int pomodoroBreakMinutes;
}
