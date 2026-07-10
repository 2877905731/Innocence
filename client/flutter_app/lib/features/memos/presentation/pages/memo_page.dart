import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/memos/domain/models/memo_overview.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({
    super.key,
    required this.initialOverview,
    required this.onRefresh,
    required this.onLoadDetail,
    required this.onCreateMemo,
    required this.onUpdateMemo,
    required this.onDeleteMemo,
  });

  final MemoOverview initialOverview;
  final Future<MemoOverview?> Function() onRefresh;
  final Future<MemoCardModel?> Function(int memoId) onLoadDetail;
  final Future<MemoOverview?> Function(MemoCardModel draft) onCreateMemo;
  final Future<MemoOverview?> Function(int memoId, MemoCardModel draft)
      onUpdateMemo;
  final Future<MemoOverview?> Function(int memoId) onDeleteMemo;

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  late MemoOverview _overview;
  bool _isLoading = false;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  String _memoDisplayTitle(MemoCardModel memo) {
    if (memo.title.trim().isNotEmpty) {
      return memo.title.trim();
    }
    if (memo.content.trim().isNotEmpty) {
      return memo.content.trim().split('\n').first;
    }
    return _text('未命名备忘录', 'Untitled memo');
  }

  String _memoProgressLabel(MemoCardModel memo) {
    if (!memo.hasChecklist) {
      return _text('文字备忘', 'Text memo');
    }
    return _text(
      '${memo.checkedItemCount}/${memo.totalItemCount} 已勾选',
      '${memo.checkedItemCount}/${memo.totalItemCount} checked',
    );
  }

  String _memoSummaryText(MemoCardModel memo) {
    if (memo.content.trim().isNotEmpty) {
      return memo.content.trim();
    }
    if (memo.checkItems.isNotEmpty) {
      return memo.checkItems.map((item) => item.itemText).join('  ');
    }
    return _text('还没有内容', 'No content yet');
  }

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
  }

  Future<void> _refresh() async {
    await _runOverviewAction(
      widget.onRefresh,
      fallbackMessage:
          _text('当前无法刷新备忘录。', 'Unable to refresh memos right now.'),
    );
  }

  Future<void> _createMemo() async {
    final draft = await _openEditor();
    if (draft == null) {
      return;
    }
    await _runOverviewAction(
      () => widget.onCreateMemo(draft),
      fallbackMessage: _text('当前无法创建备忘录。', 'Unable to create the memo.'),
    );
  }

  Future<void> _editMemo(MemoCardModel memo) async {
    final detail = await widget.onLoadDetail(memo.memoId) ?? memo;
    if (!mounted) {
      return;
    }
    final draft = await _openEditor(initialMemo: detail);
    if (draft == null) {
      return;
    }
    await _runOverviewAction(
      () => widget.onUpdateMemo(memo.memoId, draft),
      fallbackMessage: _text('当前无法更新备忘录。', 'Unable to update the memo.'),
    );
  }

  Future<void> _deleteMemo(MemoCardModel memo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('删除备忘录', 'Delete memo')),
          content: Text(
            _text(
              '确认永久删除“${memo.displayTitle}”吗？此操作无法撤销。',
              'Delete "${memo.displayTitle}" permanently? This action cannot be undone.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text('取消', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C72),
              ),
              child: Text(_text('删除', 'Delete')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await _runOverviewAction(
      () => widget.onDeleteMemo(memo.memoId),
      fallbackMessage: _text('当前无法删除备忘录。', 'Unable to delete the memo.'),
    );
  }

  Future<MemoCardModel?> _openEditor({MemoCardModel? initialMemo}) async {
    return showDialog<MemoCardModel>(
      context: context,
      builder: (context) {
        return _MemoEditorDialog(
          initialMemo: initialMemo,
          isChinese: _isChinese,
        );
      },
    );
  }

  Future<void> _runOverviewAction(
    Future<MemoOverview?> Function() action, {
    required String fallbackMessage,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final overview = await action();
      if (!mounted) {
        return;
      }
      if (overview == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMessage)),
        );
        return;
      }
      setState(() {
        _overview = overview;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('备忘录中心', 'Memo center'),
      description: _text(
        '快速记录文字和清单，并在手机与桌面端保持同步显示。',
        'Capture text and checklists quickly, then keep the same notes visible on both phone and desktop.',
      ),
      headerActions: [
        FilledButton.icon(
          onPressed: _isLoading ? null : _createMemo,
          icon: const Icon(Icons.note_add_rounded),
          label: Text(_text('新建备忘录', 'New memo')),
        ),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _refresh,
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(
              _isLoading ? _text('刷新中', 'Refreshing') : _text('刷新', 'Refresh')),
        ),
      ],
      children: [
        GlassPanel(
          lightStyle: true,
          child: _MemoHeroCard(
            overview: _overview,
            isChinese: _isChinese,
          ),
        ),
        const SizedBox(height: 16),
        if (!_overview.hasItems)
          GlassPanel(
            lightStyle: true,
            child: _EmptyMemoState(isChinese: _isChinese),
          )
        else
          ..._overview.items.map((memo) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GlassPanel(
                lightStyle: true,
                child: _MemoCardTile(
                  memo: memo,
                  isChinese: _isChinese,
                  displayTitle: _memoDisplayTitle(memo),
                  progressLabel: _memoProgressLabel(memo),
                  summaryText: _memoSummaryText(memo),
                  onEdit: () => _editMemo(memo),
                  onDelete: () => _deleteMemo(memo),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _MemoHeroCard extends StatelessWidget {
  const _MemoHeroCard({
    required this.overview,
    required this.isChinese,
  });

  final MemoOverview overview;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final checklistCount =
        overview.items.where((item) => item.hasChecklist).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('快速记录概览', 'Quick capture overview'),
            style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          _text(
            '${overview.totalCount} 条备忘录  |  $checklistCount 条含清单  |  删除后立即生效',
            '${overview.totalCount} memos  |  $checklistCount with checklist  |  Deletes apply immediately',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MemoTag(label: _text('支持文字 + 清单', 'Text + checklist')),
            _MemoTag(label: _text('支持快速整理', 'Quick organization ready')),
            _MemoTag(label: _text('桌面挂件摘要可见', 'Desktop widget summary ready')),
          ],
        ),
      ],
    );
  }
}

class _MemoCardTile extends StatelessWidget {
  const _MemoCardTile({
    required this.memo,
    required this.isChinese,
    required this.displayTitle,
    required this.progressLabel,
    required this.summaryText,
    required this.onEdit,
    required this.onDelete,
  });

  final MemoCardModel memo;
  final bool isChinese;
  final String displayTitle;
  final String progressLabel;
  final String summaryText;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: textTheme.titleMedium?.copyWith(
                    color: SurfacePalette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  memo.updateTime.isEmpty
                      ? _text('最近更新', 'Recently updated')
                      : memo.updateTime,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await onEdit();
                  },
                  child: Text(_text('编辑', 'Edit')),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await onDelete();
                  },
                  child: Text(_text('删除', 'Delete')),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (memo.content.trim().isNotEmpty)
          Text(
            summaryText,
            style: textTheme.bodyLarge?.copyWith(
              color: SurfacePalette.ink,
            ),
          ),
        if (memo.content.trim().isNotEmpty && memo.checkItems.isNotEmpty)
          const SizedBox(height: 14),
        if (memo.checkItems.isNotEmpty)
          ...memo.checkItems.take(6).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.checked
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color:
                        item.checked ? AppColors.mint : SurfacePalette.subtle,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.itemText,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SurfacePalette.ink,
                        decoration:
                            item.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MemoTag(label: progressLabel),
            _MemoTag(
              label: memo.content.trim().isNotEmpty
                  ? _text('已保存文字', 'Text saved')
                  : _text('仅清单', 'Checklist only'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyMemoState extends StatelessWidget {
  const _EmptyMemoState({required this.isChinese});

  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('还没有备忘录', 'No memos yet'), style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          _text(
            '创建第一条备忘录，用来记录灵感、提醒或者轻量清单。',
            'Create your first memo card for ideas, reminders, or a lightweight checklist.',
          ),
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _MemoTag extends StatelessWidget {
  const _MemoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}

class _MemoEditorDialog extends StatefulWidget {
  const _MemoEditorDialog({
    this.initialMemo,
    required this.isChinese,
  });

  final MemoCardModel? initialMemo;
  final bool isChinese;

  @override
  State<_MemoEditorDialog> createState() => _MemoEditorDialogState();
}

class _MemoEditorDialogState extends State<_MemoEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late List<MemoCheckItemModel> _items;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialMemo?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.initialMemo?.content ?? '',
    );
    _items = List<MemoCheckItemModel>.from(
      widget.initialMemo?.checkItems ?? const [],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _addChecklistItem() async {
    final controller = TextEditingController();
    final itemText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('新增清单项', 'Add checklist item')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _text('事项内容', 'Item text'),
              hintText: _text('例如：复盘数学错题', 'For example: Review math mistakes'),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_text('取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(_text('添加', 'Add')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (itemText == null || itemText.isEmpty) {
      return;
    }

    setState(() {
      _items = [
        ..._items,
        MemoCheckItemModel(
          id: 0,
          itemText: itemText,
          checked: false,
          sortNo: _items.length,
        ),
      ];
    });
  }

  void _submit() {
    final draft = MemoCardModel(
      memoId: widget.initialMemo?.memoId ?? 0,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      totalItemCount: _items.length,
      checkedItemCount: _items.where((item) => item.checked).length,
      updateTime: widget.initialMemo?.updateTime ?? '',
      checkItems: _items.asMap().entries.map((entry) {
        return entry.value.copyWith(sortNo: entry.key);
      }).toList(),
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialMemo == null
            ? _text('新建备忘录', 'New memo')
            : _text('编辑备忘录', 'Edit memo'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _text('标题', 'Title'),
                  hintText: _text('可选标题', 'Optional title'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: _text('文字内容', 'Text note'),
                  hintText: _text('在这里写下备忘内容', 'Write your memo text here'),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _addChecklistItem,
                    icon: const Icon(Icons.add_task_rounded),
                    label: Text(_text('添加清单', 'Add checklist')),
                  ),
                  _MemoTag(
                    label: widget.isChinese
                        ? '${_items.where((item) => item.checked).length}/${_items.length} 已勾选'
                        : '${_items.where((item) => item.checked).length}/${_items.length} checked',
                  ),
                ],
              ),
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 16),
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SurfacePalette.softSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SurfacePalette.border),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.checked,
                            onChanged: (value) {
                              setState(() {
                                _items[index] = item.copyWith(
                                  checked: value ?? false,
                                );
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              item.itemText,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _items.removeAt(index);
                              });
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
          child: Text(_text('保存', 'Save')),
        ),
      ],
    );
  }
}
