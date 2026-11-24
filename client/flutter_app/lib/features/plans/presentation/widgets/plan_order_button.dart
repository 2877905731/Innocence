import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/widgets/themed_dialog.dart';
import '../../domain/models/plan_order.dart';

export '../../domain/models/plan_order.dart';

class DraftPlanOrderButton<T> extends StatelessWidget {
  const DraftPlanOrderButton(
      {super.key,
      required this.items,
      required this.titleOf,
      required this.onChanged,
      required this.isChinese,
      this.isBusy = false});
  final List<T> items;
  final String Function(T item) titleOf;
  final ValueChanged<List<T>> onChanged;
  final bool isChinese;
  final bool isBusy;
  @override
  Widget build(BuildContext context) {
    final snapshot = List<T>.of(items);
    return PlanOrderButton(
        order: PlanOrder(scope: 'draft', items: [
          for (final entry in snapshot.indexed)
            PlanOrderItem('${entry.$1}', titleOf(entry.$2)),
        ]),
        isChinese: isChinese,
        isBusy: isBusy,
        onSave: (order) async {
          onChanged(
              [for (final item in order.items) snapshot[int.parse(item.id)]]);
          return true;
        });
  }
}

class PlanOrderButton extends StatelessWidget {
  const PlanOrderButton(
      {super.key,
      required this.order,
      required this.isChinese,
      required this.onSave,
      this.isBusy = false});
  final PlanOrder order;
  final bool isChinese;
  final bool isBusy;
  final SavePlanOrder? onSave;
  @override
  Widget build(BuildContext context) => TextButton.icon(
        key: ValueKey(
            'sort-${order.scope}-${order.segmentId ?? order.planDate ?? order.year}'),
        icon: const Icon(Icons.swap_vert, size: 20),
        label: Text(isChinese ? '排序' : 'Sort'),
        onPressed: isBusy || onSave == null || order.items.length < 2
            ? null
            : () => showThemedDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => PlanOrderDialog(
                    order: order, isChinese: isChinese, onSave: onSave!)),
      );
}

class PlanOrderDialog extends StatefulWidget {
  const PlanOrderDialog(
      {super.key,
      required this.order,
      required this.isChinese,
      required this.onSave});
  final PlanOrder order;
  final bool isChinese;
  final SavePlanOrder onSave;
  @override
  State<PlanOrderDialog> createState() => _PlanOrderDialogState();
}

class _PlanOrderDialogState extends State<PlanOrderDialog> {
  late final List<PlanOrderItem> _items = [...widget.order.items];
  bool _saving = false;
  bool _dirty = false;
  String? _error;
  String _t(String zh, String en) => widget.isChinese ? zh : en;
  void _move(int from, int to) => setState(() {
        _items.insert(to, _items.removeAt(from));
        _dirty = true;
        _error = null;
      });
  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    var saved = false;
    try {
      saved = await widget.onSave(widget.order.withItems(List.of(_items)));
    } catch (_) {/* Keep the draft available for retry. */}
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!saved) {
        _error = _t('排序未保存。请重试；若计划已变化，请取消后重新打开。',
            'Order not saved. Retry, or reopen if the plan has changed.');
      }
    });
    if (saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: AlertDialog(
        title: Text(_t('调整顺序', 'Reorder tasks')),
        content: SizedBox(
            width: 560,
            height: (MediaQuery.sizeOf(context).height * .55).clamp(120, 520),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_t('拖动右侧手柄，或点击箭头上移、下移。',
                      'Drag a handle, or use the arrows to move a task.')),
                  if (widget.order.scope == 'annual')
                    Text(_t(
                        '此处显示该年全部任务。', 'All tasks for this year are shown.')),
                  if (widget.order.scope == 'draft')
                    Text(_t('调整后还需保存当前编辑的计划。',
                        'Save the edited plan to keep this order.')),
                  const SizedBox(height: 12),
                  Expanded(
                      child: ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: _items.length,
                          // Keep compatibility with the Flutter OH SDK.
                          // ignore: deprecated_member_use
                          onReorder: (from, to) {
                            if (!_saving) _move(from, to > from ? to - 1 : to);
                          },
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                                key: ValueKey(item.id),
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.title),
                                subtitle: item.detail.isEmpty
                                    ? null
                                    : Text(item.detail,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          key: ValueKey('order-up-${item.id}'),
                                          tooltip: _t('上移', 'Move up'),
                                          onPressed: _saving || index == 0
                                              ? null
                                              : () => _move(index, index - 1),
                                          icon: const Icon(Icons.arrow_upward,
                                              size: 20)),
                                      IconButton(
                                          key:
                                              ValueKey('order-down-${item.id}'),
                                          tooltip: _t('下移', 'Move down'),
                                          onPressed: _saving ||
                                                  index == _items.length - 1
                                              ? null
                                              : () => _move(index, index + 1),
                                          icon: const Icon(Icons.arrow_downward,
                                              size: 20)),
                                      ReorderableDragStartListener(
                                          index: index,
                                          enabled: !_saving,
                                          child: Tooltip(
                                              message:
                                                  _t('拖动排序', 'Drag to reorder'),
                                              child: const SizedBox(
                                                  width: 40,
                                                  height: 48,
                                                  child: Icon(
                                                      Icons.drag_handle)))),
                                    ]));
                          })),
                  if (_error != null)
                    Semantics(
                        liveRegion: true,
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                ])),
        actions: [
          TextButton(
              onPressed: _saving ? null : () => Navigator.of(context).pop(),
              child: Text(_t('取消', 'Cancel'))),
          FilledButton(
              key: const ValueKey('save-plan-order'),
              onPressed: _saving || !_dirty ? null : _save,
              child: Text(
                  _saving ? _t('保存中…', 'Saving…') : _t('保存顺序', 'Save order'))),
        ],
      ));
}
