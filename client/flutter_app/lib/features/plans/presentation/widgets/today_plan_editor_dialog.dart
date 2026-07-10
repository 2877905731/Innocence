import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
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
  late final List<_EditablePlanBlock> _blocks;
  late final List<_EditableFlexibleTask> _flexibleTasks;

  int? _pendingStartSlot;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController(
      text: widget.initialPlan.planName == 'Today'
          ? ''
          : widget.initialPlan.planName,
    );
    _blocks = widget.initialPlan.scheduledItems
        .map(_EditablePlanBlock.fromTodayPlanItem)
        .toList();
    _flexibleTasks = widget.initialPlan.items
        .where((item) => !item.hasSchedule)
        .map(_EditableFlexibleTask.fromTodayPlanItem)
        .toList();
  }

  @override
  void dispose() {
    _planNameController.dispose();
    for (final block in _blocks) {
      block.dispose();
    }
    for (final task in _flexibleTasks) {
      task.dispose();
    }
    super.dispose();
  }

  void _handleSlotTap(int slot) {
    setState(() {
      _validationMessage = null;

      if (_pendingStartSlot == null) {
        _pendingStartSlot = slot;
        return;
      }

      if (slot == _pendingStartSlot) {
        final start = slot;
        final endExclusive = slot + 1;
        if (_hasOverlap(start, endExclusive)) {
          _validationMessage = 'This time range overlaps an existing block.';
          _pendingStartSlot = null;
          return;
        }
        _blocks.add(_EditablePlanBlock(
          titleController: TextEditingController(),
          startSlot: start,
          endSlot: endExclusive,
          completed: false,
        ));
        _blocks.sort((left, right) => left.startSlot.compareTo(right.startSlot));
        _pendingStartSlot = null;
        return;
      }

      final start = _pendingStartSlot! < slot ? _pendingStartSlot! : slot;
      final endExclusive = (_pendingStartSlot! < slot ? slot : _pendingStartSlot!) + 1;

      if (_hasOverlap(start, endExclusive)) {
        _validationMessage = 'This time range overlaps an existing block.';
        _pendingStartSlot = null;
        return;
      }

      _blocks.add(_EditablePlanBlock(
        titleController: TextEditingController(),
        startSlot: start,
        endSlot: endExclusive,
        completed: false,
      ));
      _blocks.sort((left, right) => left.startSlot.compareTo(right.startSlot));
      _pendingStartSlot = null;
    });
  }

  bool _hasOverlap(int startSlot, int endSlot, {int? ignoreIndex}) {
    for (var index = 0; index < _blocks.length; index++) {
      if (ignoreIndex != null && ignoreIndex == index) {
        continue;
      }
      final block = _blocks[index];
      if (startSlot < block.endSlot && endSlot > block.startSlot) {
        return true;
      }
    }
    return false;
  }

  void _removeBlock(int index) {
    final removed = _blocks.removeAt(index);
    removed.dispose();
    setState(() {
      _validationMessage = null;
    });
  }

  void _addFlexibleTask() {
    setState(() {
      _flexibleTasks.add(_EditableFlexibleTask.empty());
      _validationMessage = null;
    });
  }

  void _removeFlexibleTask(int index) {
    if (_flexibleTasks.length == 1) {
      _flexibleTasks[index].clear();
      setState(() {
        _validationMessage = null;
      });
      return;
    }

    final removed = _flexibleTasks.removeAt(index);
    removed.dispose();
    setState(() {
      _validationMessage = null;
    });
  }

  void _save() {
    final scheduledItems = <TodayPlanItem>[];
    final sortedBlocks = List<_EditablePlanBlock>.from(_blocks)
      ..sort((left, right) => left.startSlot.compareTo(right.startSlot));

    for (var index = 0; index < sortedBlocks.length; index++) {
      final block = sortedBlocks[index];
      final title = block.titleController.text.trim();
      if (title.isEmpty) {
        setState(() {
          _validationMessage = 'Every time block needs a task name before saving.';
        });
        return;
      }
      scheduledItems.add(
        TodayPlanItem(
          id: 0,
          title: title,
          completed: block.completed,
          plannedMinutes: (block.endSlot - block.startSlot) * 30,
          actualMinutes: 0,
          startSlot: block.startSlot,
          endSlot: block.endSlot,
          sortOrder: index,
        ),
      );
    }

    final flexibleItems = <TodayPlanItem>[];
    for (var index = 0; index < _flexibleTasks.length; index++) {
      final task = _flexibleTasks[index];
      final title = task.titleController.text.trim();
      if (title.isEmpty) {
        continue;
      }
      final plannedMinutes =
          int.tryParse(task.minutesController.text.trim()) ?? 0;
      flexibleItems.add(
        TodayPlanItem(
          id: 0,
          title: title,
          completed: task.completed,
          plannedMinutes: plannedMinutes < 0 ? 0 : plannedMinutes,
          actualMinutes: 0,
          startSlot: null,
          endSlot: null,
          sortOrder: scheduledItems.length + index,
        ),
      );
    }

    final result = TodayPlan.empty(widget.initialPlan.planDate).copyWith(
      planName: _planNameController.text.trim().isEmpty
          ? 'Today'
          : _planNameController.text.trim(),
      items: [...scheduledItems, ...flexibleItems],
    );
    Navigator.of(context).pop(result);
  }

  Color _slotColor(int slot) {
    if (_pendingStartSlot == slot) {
      return AppColors.mint.withValues(alpha: 0.5);
    }

    final blockIndex = _blocks.indexWhere(
      (block) => slot >= block.startSlot && slot < block.endSlot,
    );
    if (blockIndex >= 0) {
      final block = _blocks[blockIndex];
      return block.completed
          ? AppColors.mint.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.18);
    }

    return Colors.white.withValues(alpha: 0.05);
  }

  String? _slotLabel(int slot) {
    if (slot.isEven) {
      return TodayPlan.slotLabel(slot);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Short plan scheduler',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap one half-hour slot, then tap another slot to create a study block for today.',
                style: textTheme.bodyMedium,
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
                child: ListView(
                  children: [
                    _SectionTitle(
                      title: 'Time axis',
                      subtitle:
                          '48 half-hour units. Existing blocks are highlighted.',
                    ),
                    const SizedBox(height: 12),
                    _TimelineGrid(
                      slotColorBuilder: _slotColor,
                      slotLabelBuilder: _slotLabel,
                      onTapSlot: _handleSlotTap,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _LegendChip(
                          color: Colors.white.withValues(alpha: 0.12),
                          label: 'Empty slot',
                        ),
                        _LegendChip(
                          color: AppColors.mint.withValues(alpha: 0.5),
                          label: 'Selected anchor',
                        ),
                        _LegendChip(
                          color: Colors.white.withValues(alpha: 0.18),
                          label: 'Scheduled block',
                        ),
                        _LegendChip(
                          color: AppColors.mint.withValues(alpha: 0.45),
                          label: 'Completed block',
                        ),
                      ],
                    ),
                    if (_validationMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _validationMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade200,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Scheduled blocks',
                      subtitle:
                          'Name each block and optionally mark it completed.',
                    ),
                    const SizedBox(height: 12),
                    if (_blocks.isEmpty)
                      _EmptyStateCard(
                        message:
                            'No time blocks yet. Tap the time axis above to create your first block.',
                      )
                    else
                      ...List.generate(_blocks.length, (index) {
                        final block = _blocks[index];
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: index == _blocks.length - 1 ? 0 : 12),
                          child: _ScheduledBlockCard(
                            index: index,
                            block: block,
                            onDelete: () => _removeBlock(index),
                            onChanged: () {
                              setState(() {
                                _validationMessage = null;
                              });
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'Flexible tasks',
                      subtitle:
                          'These tasks do not need fixed time blocks, but still appear in today progress.',
                    ),
                    const SizedBox(height: 12),
                    if (_flexibleTasks.isEmpty)
                      _EmptyStateCard(
                        message:
                            'No flexible tasks yet. Add one if you want extra checklist items outside the timeline.',
                      )
                    else
                      ...List.generate(_flexibleTasks.length, (index) {
                        final task = _flexibleTasks[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _flexibleTasks.length - 1 ? 0 : 12,
                          ),
                          child: _FlexibleTaskCard(
                            index: index,
                            task: task,
                            onDelete: () => _removeFlexibleTask(index),
                            onChanged: () {
                              setState(() {
                                _validationMessage = null;
                              });
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _addFlexibleTask,
                        icon: const Icon(Icons.add_task_rounded),
                        label: const Text('Add flexible task'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _pendingStartSlot = null;
                      _validationMessage = null;
                    }),
                    child: const Text('Clear selection'),
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

class _TimelineGrid extends StatelessWidget {
  const _TimelineGrid({
    required this.slotColorBuilder,
    required this.slotLabelBuilder,
    required this.onTapSlot,
  });

  final Color Function(int slot) slotColorBuilder;
  final String? Function(int slot) slotLabelBuilder;
  final void Function(int slot) onTapSlot;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 720 ? 4 : 2;
        final rowsPerColumn = 48 ~/ columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(columns, (columnIndex) {
            return SizedBox(
              width: columns == 4 ? (width - 36) / 4 : (width - 12) / 2,
              child: Column(
                children: List.generate(rowsPerColumn, (rowIndex) {
                  final slot = columnIndex * rowsPerColumn + rowIndex;
                  final label = slotLabelBuilder(slot);

                  return Padding(
                    padding: EdgeInsets.only(bottom: rowIndex == rowsPerColumn - 1 ? 0 : 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onTapSlot(slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: slotColorBuilder(slot),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                label ?? '',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ScheduledBlockCard extends StatelessWidget {
  const _ScheduledBlockCard({
    required this.index,
    required this.block,
    required this.onDelete,
    required this.onChanged,
  });

  final int index;
  final _EditablePlanBlock block;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Block ${index + 1}  ${TodayPlan.slotLabel(block.startSlot)} - ${TodayPlan.slotLabel(block.endSlot)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: block.titleController,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Task name',
              hintText: 'For example: English reading and note review',
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: block.completed,
            onChanged: (value) {
              block.completed = value ?? false;
              onChanged();
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('Already completed'),
          ),
        ],
      ),
    );
  }
}

class _FlexibleTaskCard extends StatelessWidget {
  const _FlexibleTaskCard({
    required this.index,
    required this.task,
    required this.onDelete,
    required this.onChanged,
  });

  final int index;
  final _EditableFlexibleTask task;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
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
                  'Flexible task ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: task.titleController,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'Task name',
              hintText: 'For example: Finish one page of chemistry notes',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: task.minutesController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Planned minutes',
                    hintText: '30',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CheckboxListTile(
                  value: task.completed,
                  onChanged: (value) {
                    task.completed = value ?? false;
                    onChanged();
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Already completed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _EditablePlanBlock {
  _EditablePlanBlock({
    required this.titleController,
    required this.startSlot,
    required this.endSlot,
    required this.completed,
  });

  factory _EditablePlanBlock.fromTodayPlanItem(TodayPlanItem item) {
    final fallbackDurationSlots = ((item.plannedMinutes <= 0
                ? 30
                : item.plannedMinutes) ~/
            30)
        .clamp(1, 48)
        .toInt();
    final resolvedStartSlot = item.startSlot ?? 0;
    final resolvedEndSlot = item.endSlot == null
        ? (resolvedStartSlot + fallbackDurationSlots).clamp(
            resolvedStartSlot + 1,
            48,
          ).toInt()
        : item.endSlot!.clamp(resolvedStartSlot + 1, 48).toInt();
    return _EditablePlanBlock(
      titleController: TextEditingController(text: item.title),
      startSlot: resolvedStartSlot,
      endSlot: resolvedEndSlot,
      completed: item.completed,
    );
  }

  final TextEditingController titleController;
  final int startSlot;
  final int endSlot;
  bool completed;

  void dispose() {
    titleController.dispose();
  }
}

class _EditableFlexibleTask {
  _EditableFlexibleTask({
    required this.titleController,
    required this.minutesController,
    required this.completed,
  });

  factory _EditableFlexibleTask.fromTodayPlanItem(TodayPlanItem item) {
    return _EditableFlexibleTask(
      titleController: TextEditingController(text: item.title),
      minutesController: TextEditingController(
        text: item.plannedMinutes > 0 ? item.plannedMinutes.toString() : '',
      ),
      completed: item.completed,
    );
  }

  factory _EditableFlexibleTask.empty() {
    return _EditableFlexibleTask(
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
