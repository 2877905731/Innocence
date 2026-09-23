import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

const _planPastelPalette = <Color>[
  Color(0xFFA7B5FF),
  Color(0xFFC8AEFF),
  Color(0xFFFFB7D9),
  Color(0xFF9EDBFF),
  Color(0xFFFFC9A8),
  Color(0xFF9EDDD8),
];

Color _planSlotColor(int paletteIndex, int offset, int slotCount) {
  final start = _planPastelPalette[paletteIndex % _planPastelPalette.length];
  final end =
      _planPastelPalette[(paletteIndex + 1) % _planPastelPalette.length];
  final progress = slotCount <= 1 ? 0.35 : offset / (slotCount - 1);
  return Color.lerp(start, end, progress) ?? start;
}

class TodayPlanEditorDialog extends StatefulWidget {
  const TodayPlanEditorDialog({
    super.key,
    required this.initialPlan,
    this.onSave,
    this.onSaveArchive,
    this.onSaveAsArchive,
    this.archiveMode = false,
    this.lockPlanName = false,
  });

  final TodayPlan initialPlan;
  final Future<void> Function(TodayPlan plan)? onSave;
  final Future<bool> Function(TodayPlan plan)? onSaveArchive;
  final Future<bool> Function(String archiveName, TodayPlan plan)?
      onSaveAsArchive;
  final bool archiveMode;
  final bool lockPlanName;

  @override
  State<TodayPlanEditorDialog> createState() => _TodayPlanEditorDialogState();
}

class _TodayPlanEditorDialogState extends State<TodayPlanEditorDialog> {
  late final TextEditingController _planNameController;
  late final List<_EditablePlanBlock> _blocks;
  late final List<_EditableFlexibleTask> _flexibleTasks;

  int? _pendingStartSlot;
  _EditablePlanBlock? _activeBlock;
  String? _validationMessage;
  bool _dirty = false;
  bool _saving = false;
  DateTime? _savedAt;
  String? _archiveSavedMessage;
  String? _pendingArchiveName;

  bool get _isChinese =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'zh';

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _planNameController = TextEditingController(
      text: widget.initialPlan.planName == 'Today'
          ? ''
          : widget.initialPlan.planName,
    );
    _planNameController.addListener(_markDirty);
    _blocks = widget.initialPlan.scheduledItems.indexed
        .map(
          (entry) => _EditablePlanBlock.fromTodayPlanItem(
            entry.$2,
            paletteIndex: entry.$1,
          ),
        )
        .toList();
    _flexibleTasks = widget.initialPlan.items
        .where((item) => !item.hasSchedule)
        .map(_EditableFlexibleTask.fromTodayPlanItem)
        .toList();
  }

  void _markDirty() {
    if (!mounted || _dirty) {
      return;
    }
    setState(() => _dirty = true);
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
      final occupiedBlock = _blockAt(slot);
      if (occupiedBlock != null) {
        _activeBlock = occupiedBlock;
        _pendingStartSlot = null;
        return;
      }

      _activeBlock = null;

      if (_pendingStartSlot == null) {
        _pendingStartSlot = slot;
        return;
      }

      if (slot == _pendingStartSlot) {
        final start = slot;
        final endExclusive = slot + 1;
        if (_hasOverlap(start, endExclusive)) {
          _validationMessage = _text(
            '该时间段与已有任务重叠。',
            'This time range overlaps an existing block.',
          );
          _pendingStartSlot = null;
          return;
        }
        _appendBlock(start, endExclusive);
        return;
      }

      final start = _pendingStartSlot! < slot ? _pendingStartSlot! : slot;
      final endExclusive =
          (_pendingStartSlot! < slot ? slot : _pendingStartSlot!) + 1;

      if (_hasOverlap(start, endExclusive)) {
        _validationMessage = _text(
          '该时间段与已有任务重叠。',
          'This time range overlaps an existing block.',
        );
        _pendingStartSlot = null;
        return;
      }

      _appendBlock(start, endExclusive);
    });
  }

  void _appendBlock(int startSlot, int endSlot) {
    final block = _EditablePlanBlock(
      titleController: TextEditingController(
        text: _text(
          '学习任务 ${_blocks.length + 1}',
          'Study block ${_blocks.length + 1}',
        ),
      ),
      startSlot: startSlot,
      endSlot: endSlot,
      completed: false,
      paletteIndex: _nextPaletteIndex(),
    );
    _blocks.add(block);
    _blocks.sort((left, right) => left.startSlot.compareTo(right.startSlot));
    _pendingStartSlot = null;
    _activeBlock = block;
    _dirty = true;
  }

  int _nextPaletteIndex() {
    if (_blocks.isEmpty) {
      return 0;
    }
    return _blocks.map((block) => block.paletteIndex).reduce(math.max) + 1;
  }

  _EditablePlanBlock? _blockAt(int slot) {
    for (final block in _blocks) {
      if (slot >= block.startSlot && slot < block.endSlot) {
        return block;
      }
    }
    return null;
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
    if (identical(_activeBlock, removed)) {
      _activeBlock = null;
    }
    removed.dispose();
    setState(() {
      _validationMessage = null;
      _dirty = true;
    });
  }

  void _resizeBlock(
    _EditablePlanBlock block,
    int requestedStartSlot,
    int requestedEndSlot,
  ) {
    final blockIndex = _blocks.indexOf(block);
    if (blockIndex < 0) {
      return;
    }

    var minimumStart = 0;
    var maximumEnd = 48;
    for (final other in _blocks) {
      if (identical(other, block)) {
        continue;
      }
      if (other.endSlot <= block.startSlot) {
        minimumStart = math.max(minimumStart, other.endSlot);
      }
      if (other.startSlot >= block.endSlot) {
        maximumEnd = math.min(maximumEnd, other.startSlot);
      }
    }

    final nextStart =
        requestedStartSlot.clamp(minimumStart, block.endSlot - 1).toInt();
    final nextEnd =
        requestedEndSlot.clamp(block.startSlot + 1, maximumEnd).toInt();
    if (nextStart == block.startSlot && nextEnd == block.endSlot) {
      return;
    }

    setState(() {
      block.startSlot = nextStart;
      block.endSlot = nextEnd;
      _activeBlock = block;
      _pendingStartSlot = null;
      _validationMessage = null;
      _dirty = true;
    });
  }

  void _addFlexibleTask() {
    setState(() {
      _flexibleTasks.add(_EditableFlexibleTask.empty());
      _validationMessage = null;
      _dirty = true;
    });
  }

  void _removeFlexibleTask(int index) {
    if (_flexibleTasks.length == 1) {
      _flexibleTasks[index].clear();
      setState(() {
        _validationMessage = null;
        _dirty = true;
      });
      return;
    }

    final removed = _flexibleTasks.removeAt(index);
    removed.dispose();
    setState(() {
      _validationMessage = null;
      _dirty = true;
    });
  }

  TodayPlan _draftPlan() {
    final scheduledItems = <TodayPlanItem>[];
    final sortedBlocks = List<_EditablePlanBlock>.from(_blocks)
      ..sort((left, right) => left.startSlot.compareTo(right.startSlot));

    for (var index = 0; index < sortedBlocks.length; index++) {
      final block = sortedBlocks[index];
      final enteredTitle = block.titleController.text.trim();
      final title = enteredTitle.isEmpty
          ? _text('学习任务 ${index + 1}', 'Study block ${index + 1}')
          : enteredTitle;
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

    final enteredPlanName = _planNameController.text.trim();
    return TodayPlan.empty(widget.initialPlan.planDate).copyWith(
      planName: enteredPlanName.isEmpty ? 'Today' : enteredPlanName,
      items: [...scheduledItems, ...flexibleItems],
    );
  }

  Future<void> _saveAsArchive() async {
    final onSaveAsArchive = widget.onSaveAsArchive;
    if (onSaveAsArchive == null) {
      return;
    }
    final draft = _draftPlan();
    if (!draft.hasItems) {
      setState(() {
        _validationMessage = _text(
          '请先添加任务，再保存为任务存档。',
          'Add a task before saving an archive.',
        );
      });
      return;
    }
    var enteredArchiveName = _pendingArchiveName ??
        (draft.planName == 'Today' ? '' : draft.planName);
    final archiveName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('保存为任务存档', 'Save as task archive')),
        content: TextFormField(
          initialValue: enteredArchiveName,
          autofocus: true,
          decoration: InputDecoration(
            labelText: _text('存档名称', 'Archive name'),
            helperText: _text(
              '仅保存存档；当天安排请另按“保存当天计划”。',
              'This saves the archive. Save the daily plan separately.',
            ),
          ),
          onChanged: (value) => enteredArchiveName = value,
          onFieldSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(enteredArchiveName.trim()),
            child: Text(_text('保存存档', 'Save archive')),
          ),
        ],
      ),
    );
    if (archiveName == null || !mounted) {
      return;
    }
    if (archiveName.isEmpty) {
      setState(() {
        _validationMessage = _text(
          '请输入任务存档名称。',
          'Enter a task archive name.',
        );
      });
      return;
    }
    _pendingArchiveName = archiveName;
    setState(() => _saving = true);
    try {
      final saved = await onSaveAsArchive(archiveName, draft);
      if (mounted) {
        setState(() {
          _archiveSavedMessage = saved
              ? _text(
                  '当前安排已保存为任务存档。',
                  'Current plan saved as a task archive.',
                )
              : null;
          _validationMessage = saved
              ? null
              : _text('存档未保存，请重试。', 'Archive not saved. Please retry.');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _save() async {
    final enteredPlanName = _planNameController.text.trim();
    if (widget.archiveMode && enteredPlanName.isEmpty) {
      setState(() {
        _validationMessage = _text(
          '请输入任务存档名称。',
          'Enter a task archive name.',
        );
      });
      return;
    }
    final result = _draftPlan();
    if (widget.archiveMode && !result.hasItems) {
      setState(() {
        _validationMessage = _text(
          '请至少添加一个任务后再保存存档。',
          'Add at least one task before saving the archive.',
        );
      });
      return;
    }

    final onSave = widget.onSave;
    final onSaveArchive = widget.onSaveArchive;
    if (widget.archiveMode && onSaveArchive != null) {
      setState(() => _saving = true);
      try {
        final saved = await onSaveArchive(result);
        if (!mounted) {
          return;
        }
        if (saved) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _validationMessage = _text(
              '存档未保存，请重试。',
              'Archive not saved. Please retry.',
            );
          });
        }
      } finally {
        if (mounted) {
          setState(() => _saving = false);
        }
      }
      return;
    }
    if (onSave == null) {
      Navigator.of(context).pop(result);
      return;
    }
    setState(() => _saving = true);
    await onSave(result);
    if (!mounted) {
      return;
    }
    if (widget.archiveMode) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _dirty = false;
      _savedAt = DateTime.now();
    });
  }

  Future<void> _requestClose() async {
    if (!_dirty) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('有未保存更改', 'Unsaved changes')),
        content: Text(
          _text('关闭后，本次未保存的修改会丢失。',
              'Closing will discard the changes made since the last save.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_text('继续编辑', 'Keep editing')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text('放弃更改', 'Discard')),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewport = MediaQuery.sizeOf(context);
    final compactHeight = viewport.height < 700;
    final dialogHeight = (viewport.height - 40).clamp(480.0, 820.0);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _requestClose();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: SizedBox(
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.archiveMode
                        ? _text('任务存档编辑器', 'Task archive editor')
                        : _text('今日计划时间安排', 'Today plan scheduler'),
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _text(
                      widget.archiveMode
                          ? '建立可重复套用的任务与时间结构；每一格代表 30 分钟。'
                          : '先选择开始时间，再选择结束时间；每一格代表 30 分钟。',
                      widget.archiveMode
                          ? 'Build a reusable task and time structure. Each bar represents 30 minutes.'
                          : 'Choose a start time, then an end time. Each bar represents 30 minutes.',
                    ),
                    style: textTheme.bodyMedium,
                  ),
                  if (!widget.archiveMode &&
                      widget.onSaveAsArchive != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const ValueKey('today-plan-save-as-archive'),
                        onPressed: _saving ? null : _saveAsArchive,
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: Text(_text(
                          '保存当前安排为任务存档',
                          'Save current plan as archive',
                        )),
                      ),
                    ),
                    if (_archiveSavedMessage != null)
                      Text(
                        _archiveSavedMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: _planNameController,
                    enabled: !widget.lockPlanName,
                    decoration: InputDecoration(
                      labelText: widget.archiveMode
                          ? _text('存档名称', 'Archive name')
                          : _text('计划名称', 'Plan name'),
                      hintText: _text(
                        widget.archiveMode ? '例如：工作日学习安排' : '留空则使用“今日计划”',
                        widget.archiveMode
                            ? 'For example: Weekday study routine'
                            : 'Leave blank to use Today',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DaylightTimeline(
                    height: compactHeight ? 176 : 224,
                    blocks: _blocks,
                    pendingStartSlot: _pendingStartSlot,
                    activeBlock: _activeBlock,
                    isChinese: _isChinese,
                    onTapSlot: _handleSlotTap,
                    onResizeBlock: _resizeBlock,
                  ),
                  if (_validationMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _validationMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      children: [
                        _SectionTitle(
                          title: _text('已安排时间段', 'Scheduled blocks'),
                          subtitle: _text(
                            '点击已有时段后可拖动首尾调整；任务名可在这里继续修改。',
                            'Select a block and drag either edge to resize it; edit its task name here.',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_blocks.isEmpty)
                          _EmptyStateCard(
                            message: _text(
                              '尚未安排时间。请在上方时间轴选择开始与结束位置。',
                              'No time blocks yet. Choose a start and end above.',
                            ),
                          )
                        else
                          ...List.generate(_blocks.length, (index) {
                            final block = _blocks[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == _blocks.length - 1 ? 0 : 12,
                              ),
                              child: _ScheduledBlockCard(
                                index: index,
                                block: block,
                                isChinese: _isChinese,
                                onDelete: () => _removeBlock(index),
                                onChanged: () {
                                  setState(() {
                                    _validationMessage = null;
                                    _dirty = true;
                                  });
                                },
                              ),
                            );
                          }),
                        const SizedBox(height: 22),
                        _SectionTitle(
                          title: _text('灵活任务', 'Flexible tasks'),
                          subtitle: _text(
                            '无需固定时间，也会计入今日进度。',
                            'These tasks do not need fixed times, but still count toward today.',
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_flexibleTasks.isEmpty)
                          _EmptyStateCard(
                            message: _text(
                              '暂无灵活任务，可按需添加。',
                              'No flexible tasks yet. Add one when needed.',
                            ),
                          )
                        else
                          ...List.generate(_flexibleTasks.length, (index) {
                            final task = _flexibleTasks[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    index == _flexibleTasks.length - 1 ? 0 : 12,
                              ),
                              child: _FlexibleTaskCard(
                                index: index,
                                task: task,
                                isChinese: _isChinese,
                                onDelete: () => _removeFlexibleTask(index),
                                onChanged: () {
                                  setState(() {
                                    _validationMessage = null;
                                    _dirty = true;
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
                            label: Text(
                              _text('添加灵活任务', 'Add flexible task'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (widget.onSave != null)
                        Text(
                          _dirty
                              ? _text('有未保存更改', 'Unsaved changes')
                              : _savedAt == null
                                  ? _text('尚未修改', 'No changes yet')
                                  : _text(
                                      '已保存于 ${_savedAt!.hour.toString().padLeft(2, '0')}:${_savedAt!.minute.toString().padLeft(2, '0')}',
                                      'Saved at ${_savedAt!.hour.toString().padLeft(2, '0')}:${_savedAt!.minute.toString().padLeft(2, '0')}',
                                    ),
                          style: textTheme.bodySmall,
                        ),
                      if (widget.onSave != null) const SizedBox(width: 12),
                      TextButton(
                        onPressed: _pendingStartSlot == null
                            ? null
                            : () => setState(() {
                                  _pendingStartSlot = null;
                                  _validationMessage = null;
                                }),
                        child: Text(
                          _text('取消当前选点', 'Clear current anchor'),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _saving ? null : _requestClose,
                        child: Text(_text('关闭', 'Close')),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        key: const ValueKey('today-plan-save'),
                        onPressed: _saving || !_dirty ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                widget.archiveMode
                                    ? _text('保存任务存档', 'Save task archive')
                                    : _text('保存当天计划', 'Save daily plan'),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TimelineDragBoundary { start, end, single }

class _DaylightTimeline extends StatefulWidget {
  const _DaylightTimeline({
    required this.height,
    required this.blocks,
    required this.pendingStartSlot,
    required this.activeBlock,
    required this.isChinese,
    required this.onTapSlot,
    required this.onResizeBlock,
  });

  final double height;
  final List<_EditablePlanBlock> blocks;
  final int? pendingStartSlot;
  final _EditablePlanBlock? activeBlock;
  final bool isChinese;
  final void Function(int slot) onTapSlot;
  final void Function(
    _EditablePlanBlock block,
    int startSlot,
    int endSlot,
  ) onResizeBlock;

  @override
  State<_DaylightTimeline> createState() => _DaylightTimelineState();
}

class _DaylightTimelineState extends State<_DaylightTimeline> {
  int? _hoveredSlot;
  _EditablePlanBlock? _draggingBlock;
  _TimelineDragBoundary? _dragBoundary;
  int _dragOriginStart = 0;
  int _dragOriginEnd = 1;
  double _dragDistance = 0;
  double? _dragDownDx;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  String _rangeLabel(int slot) {
    return '${TodayPlan.slotLabel(slot)}–${TodayPlan.slotLabel(slot + 1)}';
  }

  _EditablePlanBlock? _blockAt(int slot) {
    for (final block in widget.blocks) {
      if (slot >= block.startSlot && slot < block.endSlot) {
        return block;
      }
    }
    return null;
  }

  void _beginResize(
    _EditablePlanBlock block,
    _TimelineDragBoundary boundary,
  ) {
    setState(() {
      _draggingBlock = block;
      _dragBoundary = boundary;
      _dragOriginStart = block.startSlot;
      _dragOriginEnd = block.endSlot;
      _dragDistance = 0;
    });
  }

  void _beginResizeAtPosition(double localDx, double width) {
    final block = widget.activeBlock;
    if (block == null || width <= 0) {
      return;
    }
    final slot = ((localDx / width) * 48).floor().clamp(0, 47).toInt();
    final isStart = slot == block.startSlot;
    final isEnd = slot == block.endSlot - 1;
    if (!isStart && !isEnd) {
      return;
    }
    _beginResize(
      block,
      isStart && isEnd
          ? _TimelineDragBoundary.single
          : isStart
              ? _TimelineDragBoundary.start
              : _TimelineDragBoundary.end,
    );
  }

  void _updateResize(DragUpdateDetails details, double slotWidth) {
    final block = _draggingBlock;
    var boundary = _dragBoundary;
    if (block == null || boundary == null || slotWidth <= 0) {
      return;
    }

    _dragDistance += details.delta.dx;
    if (boundary == _TimelineDragBoundary.single) {
      if (_dragDistance == 0) {
        return;
      }
      boundary = _dragDistance < 0
          ? _TimelineDragBoundary.start
          : _TimelineDragBoundary.end;
    }
    final slotDelta = (_dragDistance / slotWidth).round();
    if (boundary == _TimelineDragBoundary.start) {
      widget.onResizeBlock(
        block,
        _dragOriginStart + slotDelta,
        _dragOriginEnd,
      );
    } else {
      widget.onResizeBlock(
        block,
        _dragOriginStart,
        _dragOriginEnd + slotDelta,
      );
    }
  }

  void _endResize() {
    setState(() {
      _draggingBlock = null;
      _dragBoundary = null;
      _dragDistance = 0;
      _dragDownDx = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeSlot = _hoveredSlot ?? widget.pendingStartSlot;
    final activeRange = widget.activeBlock == null
        ? null
        : '${TodayPlan.slotLabel(widget.activeBlock!.startSlot)}–'
            '${TodayPlan.slotLabel(widget.activeBlock!.endSlot)}';

    return Container(
      height: widget.height,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Tooltip(
                message: _text('凌晨 00:00', 'Midnight 00:00'),
                child: Icon(
                  Icons.nightlight_round,
                  size: 18,
                  color: scheme.secondary,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      size: 20,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        activeSlot == null
                            ? activeRange ?? _text('正午 12:00', 'Noon 12:00')
                            : _rangeLabel(activeSlot),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: _text('深夜 00:00', 'Midnight 00:00'),
                child: Icon(
                  Icons.nightlight_round,
                  size: 18,
                  color: scheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxBarHeight = constraints.maxHeight - 24;
                final slotWidth = constraints.maxWidth / 48;
                return Stack(
                  children: [
                    Positioned(
                      left: constraints.maxWidth / 2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: scheme.primary.withValues(alpha: 0.36),
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragDown: (details) {
                          _dragDownDx = details.localPosition.dx;
                        },
                        onHorizontalDragStart: (details) =>
                            _beginResizeAtPosition(
                          _dragDownDx ?? details.localPosition.dx,
                          constraints.maxWidth,
                        ),
                        onHorizontalDragUpdate: (details) =>
                            _updateResize(details, slotWidth),
                        onHorizontalDragEnd: (_) => _endResize(),
                        onHorizontalDragCancel: _endResize,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(48, (slot) {
                            final centerDistance =
                                ((slot + 0.5) - 24).abs() / 24;
                            final curve = math.pow(1 - centerDistance, 0.58);
                            final barHeight =
                                30 + (maxBarHeight - 30) * curve.toDouble();
                            final block = _blockAt(slot);
                            final blockOffset =
                                block == null ? 0 : slot - block.startSlot;
                            final blockSlotCount = block == null
                                ? 1
                                : block.endSlot - block.startSlot;
                            final hovered = _hoveredSlot == slot;
                            final pending = widget.pendingStartSlot == slot;
                            final selected = block != null;
                            final active = selected &&
                                identical(block, widget.activeBlock);
                            final startHandle =
                                active && slot == block.startSlot;
                            final endHandle =
                                active && slot == block.endSlot - 1;
                            var barColor = selected
                                ? _planSlotColor(
                                    block.paletteIndex,
                                    blockOffset,
                                    blockSlotCount,
                                  ).withValues(
                                    alpha: block.completed ? 0.56 : 0.86,
                                  )
                                : scheme.onSurface.withValues(alpha: 0.20);
                            if (pending) {
                              barColor = scheme.primary.withValues(alpha: 0.90);
                            } else if (hovered) {
                              barColor = Color.lerp(
                                    barColor,
                                    Colors.white,
                                    selected ? 0.18 : 0.42,
                                  ) ??
                                  barColor;
                            }

                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Tooltip(
                                    message: startHandle || endHandle
                                        ? _text(
                                            '${_rangeLabel(slot)} · 拖动调整边界',
                                            '${_rangeLabel(slot)} · drag to resize',
                                          )
                                        : _rangeLabel(slot),
                                    child: Semantics(
                                      button: true,
                                      selected: selected || pending,
                                      label: _rangeLabel(slot),
                                      child: MouseRegion(
                                        cursor: startHandle || endHandle
                                            ? SystemMouseCursors.resizeLeftRight
                                            : SystemMouseCursors.click,
                                        onEnter: (_) =>
                                            setState(() => _hoveredSlot = slot),
                                        onExit: (_) =>
                                            setState(() => _hoveredSlot = null),
                                        child: GestureDetector(
                                          key: ValueKey(
                                            'today-plan-slot-$slot',
                                          ),
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => widget.onTapSlot(slot),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            curve: Curves.easeOutCubic,
                                            height: barHeight,
                                            transform:
                                                Matrix4.translationValues(
                                              0,
                                              hovered ? -7 : 0,
                                              0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: barColor,
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(999),
                                                bottom: Radius.circular(5),
                                              ),
                                              border: Border.all(
                                                width: startHandle || endHandle
                                                    ? 1.8
                                                    : 1,
                                                color: hovered ||
                                                        pending ||
                                                        startHandle ||
                                                        endHandle
                                                    ? scheme.onSurface
                                                        .withValues(alpha: 0.74)
                                                    : scheme.outlineVariant,
                                              ),
                                              boxShadow: hovered || active
                                                  ? [
                                                      BoxShadow(
                                                        color:
                                                            barColor.withValues(
                                                          alpha: hovered
                                                              ? 0.48
                                                              : 0.28,
                                                        ),
                                                        blurRadius:
                                                            hovered ? 18 : 10,
                                                        offset:
                                                            const Offset(0, 8),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Stack(
                                              children: [
                                                if (startHandle)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      key: ValueKey(
                                                        'today-plan-resize-start-'
                                                        '${block.paletteIndex}',
                                                      ),
                                                      width: 2,
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 2,
                                                      ),
                                                      color: scheme.onSurface,
                                                    ),
                                                  ),
                                                if (endHandle)
                                                  Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      key: ValueKey(
                                                        'today-plan-resize-end-'
                                                        '${block.paletteIndex}',
                                                      ),
                                                      width: 2,
                                                      margin:
                                                          const EdgeInsets.only(
                                                        right: 2,
                                                      ),
                                                      color: scheme.onSurface,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['00:00', '06:00', '12:00', '18:00', '00:00']
                .map(
                  (label) => Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: label == '12:00'
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ScheduledBlockCard extends StatelessWidget {
  const _ScheduledBlockCard({
    required this.index,
    required this.block,
    required this.isChinese,
    required this.onDelete,
    required this.onChanged,
  });

  final int index;
  final _EditablePlanBlock block;
  final bool isChinese;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final slotCount = block.endSlot - block.startSlot;
    final accentColor = _planSlotColor(
      block.paletteIndex,
      slotCount ~/ 2,
      slotCount,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '${_text('时间段', 'Block')} ${index + 1}  '
                  '${TodayPlan.slotLabel(block.startSlot)}–'
                  '${TodayPlan.slotLabel(block.endSlot)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _AnimatedPlanStrips(
                  paletteIndex: block.paletteIndex,
                  slotCount: slotCount,
                  rangeKey: '${block.startSlot}-${block.endSlot}',
                ),
              ),
              const SizedBox(width: 6),
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
            decoration: InputDecoration(
              labelText: _text('任务名称', 'Task name'),
              hintText: _text(
                '例如：英语阅读与笔记复习',
                'For example: English reading and note review',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            type: MaterialType.transparency,
            child: CheckboxListTile(
              value: block.completed,
              onChanged: (value) {
                block.completed = value ?? false;
                onChanged();
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(_text('已经完成', 'Already completed')),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPlanStrips extends StatelessWidget {
  const _AnimatedPlanStrips({
    required this.paletteIndex,
    required this.slotCount,
    required this.rangeKey,
  });

  final int paletteIndex;
  final int slotCount;
  final String rangeKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$slotCount half-hour slots',
      child: SizedBox(
        key: ValueKey('today-plan-mini-strips-$paletteIndex-$rangeKey'),
        height: 24,
        child: TweenAnimationBuilder<double>(
          key: ValueKey('today-plan-mini-strip-animation-$rangeKey'),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          curve: Curves.easeOutBack,
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scaleX: value,
              scaleY: value,
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(slotCount, (slot) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.8),
                  child: DecoratedBox(
                    key: ValueKey(
                      'today-plan-mini-strip-$paletteIndex-$slot',
                    ),
                    decoration: BoxDecoration(
                      color: _planSlotColor(
                        paletteIndex,
                        slot,
                        slotCount,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FlexibleTaskCard extends StatelessWidget {
  const _FlexibleTaskCard({
    required this.index,
    required this.task,
    required this.isChinese,
    required this.onDelete,
    required this.onChanged,
  });

  final int index;
  final _EditableFlexibleTask task;
  final bool isChinese;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  String _text(String zh, String en) => isChinese ? zh : en;

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
                  '${_text('灵活任务', 'Flexible task')} ${index + 1}',
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
            decoration: InputDecoration(
              labelText: _text('任务名称', 'Task name'),
              hintText: _text(
                '例如：完成一页化学笔记',
                'For example: Finish one page of chemistry notes',
              ),
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
                  decoration: InputDecoration(
                    labelText: _text('计划分钟数', 'Planned minutes'),
                    hintText: '30',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: CheckboxListTile(
                    value: task.completed,
                    onChanged: (value) {
                      task.completed = value ?? false;
                      onChanged();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(_text('已经完成', 'Already completed')),
                  ),
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

class _EditablePlanBlock {
  _EditablePlanBlock({
    required this.titleController,
    required this.startSlot,
    required this.endSlot,
    required this.completed,
    required this.paletteIndex,
  });

  factory _EditablePlanBlock.fromTodayPlanItem(
    TodayPlanItem item, {
    required int paletteIndex,
  }) {
    final fallbackDurationSlots =
        ((item.plannedMinutes <= 0 ? 30 : item.plannedMinutes) ~/ 30)
            .clamp(1, 48)
            .toInt();
    final resolvedStartSlot = item.startSlot ?? 0;
    final resolvedEndSlot = item.endSlot == null
        ? (resolvedStartSlot + fallbackDurationSlots)
            .clamp(
              resolvedStartSlot + 1,
              48,
            )
            .toInt()
        : item.endSlot!.clamp(resolvedStartSlot + 1, 48).toInt();
    return _EditablePlanBlock(
      titleController: TextEditingController(text: item.title),
      startSlot: resolvedStartSlot,
      endSlot: resolvedEndSlot,
      completed: item.completed,
      paletteIndex: paletteIndex,
    );
  }

  final TextEditingController titleController;
  int startSlot;
  int endSlot;
  bool completed;
  final int paletteIndex;

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
