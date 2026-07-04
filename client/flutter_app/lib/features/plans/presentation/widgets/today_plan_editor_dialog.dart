import 'package:flutter/material.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

class TodayPlanEditorDialog extends StatefulWidget {
  const TodayPlanEditorDialog({
    super.key,
    required this.initialPlan,
  });

  final TodayPlan initialPlan;

  @override
  State<TodayPlanEditorDialog> createState() => _TodayPlanEditorDialogState();
}

class _TodayPlanEditorDialogState extends State<TodayPlanEditorDialog> {
  late final TextEditingController _planNameController;
  late final List<_EditablePlanItem> _items;

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController(
      text: widget.initialPlan.planName == 'Today'
          ? ''
          : widget.initialPlan.planName,
    );
    _items = widget.initialPlan.items.isEmpty
        ? [_EditablePlanItem.empty()]
        : widget.initialPlan.items
            .map(_EditablePlanItem.fromTodayPlanItem)
            .toList();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_EditablePlanItem.empty());
    });
  }

  void _removeItem(int index) {
    if (_items.length == 1) {
      _items[index].clear();
      setState(() {});
      return;
    }

    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _save() {
    final items = <TodayPlanItem>[];
    for (var index = 0; index < _items.length; index++) {
      final item = _items[index];
      final title = item.titleController.text.trim();
      if (title.isEmpty) {
        continue;
      }
      final plannedMinutes = int.tryParse(item.minutesController.text.trim()) ?? 0;
      items.add(
        TodayPlanItem(
          id: 0,
          title: title,
          completed: item.completed,
          plannedMinutes: plannedMinutes < 0 ? 0 : plannedMinutes,
          actualMinutes: 0,
          sortOrder: index,
        ),
      );
    }

    final result = TodayPlan.empty(widget.initialPlan.planDate).copyWith(
      planName: _planNameController.text.trim().isEmpty
          ? 'Today'
          : _planNameController.text.trim(),
      items: items,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit today plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'This is the first step of the study-plan module. '
                'You can maintain the task list for today here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _planNameController,
                decoration: const InputDecoration(
                  labelText: 'Plan name',
                  hintText: 'Leave blank to use Today',
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Task ${index + 1}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeItem(index),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: item.titleController,
                            decoration: const InputDecoration(
                              labelText: 'Task title',
                              hintText: 'For example: Math wrong-answer review',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: item.minutesController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Planned minutes',
                                    hintText: '60',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CheckboxListTile(
                                  value: item.completed,
                                  onChanged: (value) {
                                    setState(() {
                                      item.completed = value ?? false;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Already completed'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add task'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save today plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditablePlanItem {
  _EditablePlanItem({
    required this.titleController,
    required this.minutesController,
    required this.completed,
  });

  factory _EditablePlanItem.fromTodayPlanItem(TodayPlanItem item) {
    return _EditablePlanItem(
      titleController: TextEditingController(text: item.title),
      minutesController: TextEditingController(
        text: item.plannedMinutes > 0 ? item.plannedMinutes.toString() : '',
      ),
      completed: item.completed,
    );
  }

  factory _EditablePlanItem.empty() {
    return _EditablePlanItem(
      titleController: TextEditingController(),
      minutesController: TextEditingController(),
      completed: false,
    );
  }

  final TextEditingController titleController;
  final TextEditingController minutesController;
  bool completed;

  void clear() {
    titleController.clear();
    minutesController.clear();
    completed = false;
  }

  void dispose() {
    titleController.dispose();
    minutesController.dispose();
  }
}
