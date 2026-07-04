import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

class TodayPlanPanel extends StatelessWidget {
  const TodayPlanPanel({
    super.key,
    required this.plan,
    required this.isBusy,
    required this.onEdit,
    required this.onToggleItem,
  });

  final TodayPlan plan;
  final bool isBusy;
  final Future<void> Function() onEdit;
  final Future<void> Function(int index, bool value) onToggleItem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today plan', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    plan.planName,
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: isBusy
                  ? null
                  : () async {
                      await onEdit();
                    },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '${plan.completedCount}/${plan.totalCount} tasks finished  •  '
          '${plan.completedDurationLabel}/${plan.plannedDurationLabel}',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: plan.completionRatio,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation(AppColors.mint),
          ),
        ),
        const SizedBox(height: 16),
        if (!plan.hasItems)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'No tasks for today yet. Tap Edit to create your first daily list.',
              style: textTheme.bodyMedium,
            ),
          )
        else
          ...List.generate(plan.items.length, (index) {
            final item = plan.items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == plan.items.length - 1 ? 0 : 10),
              child: _PlanChecklistRow(
                item: item,
                isBusy: isBusy,
                onChanged: (value) async {
                  await onToggleItem(index, value);
                },
              ),
            );
          }),
      ],
    );
  }
}

class _PlanChecklistRow extends StatelessWidget {
  const _PlanChecklistRow({
    required this.item,
    required this.isBusy,
    required this.onChanged,
  });

  final TodayPlanItem item;
  final bool isBusy;
  final Future<void> Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: item.completed,
            onChanged: isBusy
                ? null
                : (value) async {
                    await onChanged(value ?? false);
                  },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      decoration: item.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.plannedMinutes > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Planned ${item.plannedMinutes} min',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
