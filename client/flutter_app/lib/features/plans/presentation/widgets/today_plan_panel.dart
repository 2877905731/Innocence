import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/week_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';

class TodayPlanPanel extends StatelessWidget {
  const TodayPlanPanel({
    super.key,
    this.lightStyle = false,
    required this.plan,
    required this.weekPlanOverview,
    required this.weeklyTemplates,
    required this.isBusy,
    required this.onEdit,
    required this.onOpenPlanDate,
    required this.onPreviousWeek,
    required this.onCurrentWeek,
    required this.onNextWeek,
    required this.onSaveTemplate,
    required this.onSaveTemplateForDay,
    required this.onApplyTemplate,
    required this.onApplyTemplateToDate,
    required this.onDeleteTemplate,
    required this.onCopyDay,
    required this.onCopyDayToDates,
    required this.onClearDay,
    required this.onApplyTemplateToDays,
    required this.onQuickArrangeWeek,
    required this.onToggleItem,
  });

  final bool lightStyle;
  final TodayPlan plan;
  final WeekPlanOverview weekPlanOverview;
  final List<WeeklyPlanTemplate> weeklyTemplates;
  final bool isBusy;
  final Future<void> Function() onEdit;
  final Future<void> Function(String planDate) onOpenPlanDate;
  final Future<void> Function() onPreviousWeek;
  final Future<void> Function() onCurrentWeek;
  final Future<void> Function() onNextWeek;
  final Future<void> Function() onSaveTemplate;
  final Future<void> Function(String planDate) onSaveTemplateForDay;
  final Future<void> Function(int templateId) onApplyTemplate;
  final Future<void> Function(int templateId, String planDate) onApplyTemplateToDate;
  final Future<void> Function(int templateId) onDeleteTemplate;
  final Future<void> Function(String sourcePlanDate, String targetPlanDate)
      onCopyDay;
  final Future<void> Function(String sourcePlanDate, List<String> targetPlanDates)
      onCopyDayToDates;
  final Future<void> Function(String planDate) onClearDay;
  final Future<void> Function(int templateId, List<String> planDates)
      onApplyTemplateToDays;
  final Future<void> Function(
    Map<String, int> templateAssignments,
    List<String> clearDates,
  ) onQuickArrangeWeek;
  final Future<void> Function(int index, bool value) onToggleItem;

  Future<void> _openApplyTemplateDialog(
    BuildContext context,
    WeekPlanDay day,
  ) async {
    if (weeklyTemplates.isEmpty) {
      return;
    }

    final selectedTemplateId = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Apply template to ${day.weekdayLabel}'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: weeklyTemplates.map((template) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(template.templateName),
                    subtitle: Text(
                      '${template.itemCount} tasks | ${template.plannedDurationLabel}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(template.id),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedTemplateId == null) {
      return;
    }

    await onApplyTemplateToDate(selectedTemplateId, day.planDate);
  }

  Future<void> _openBatchApplyTemplateDialog(BuildContext context) async {
    if (weeklyTemplates.isEmpty || weekPlanOverview.days.isEmpty) {
      return;
    }

    var selectedTemplateId = weeklyTemplates.first.id;
    final selectedDates = <String>{};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Apply template to multiple days'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<int>(
                        initialValue: selectedTemplateId,
                        decoration: const InputDecoration(
                          labelText: 'Weekly template',
                        ),
                        items: weeklyTemplates.map((template) {
                          return DropdownMenuItem<int>(
                            value: template.id,
                            child: Text(template.templateName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            selectedTemplateId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose target days',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...weekPlanOverview.days.map((day) {
                        return CheckboxListTile(
                          value: selectedDates.contains(day.planDate),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${day.weekdayLabel}  ${day.planDate}'),
                          subtitle: Text(day.hasPlan ? day.planName : 'No plan yet'),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedDates.add(day.planDate);
                              } else {
                                selectedDates.remove(day.planDate);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton.tonal(
                  onPressed: selectedDates.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(true),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedDates.isEmpty) {
      return;
    }

    await onApplyTemplateToDays(
      selectedTemplateId,
      selectedDates.toList(),
    );
  }

  Future<void> _openCopyDayDialog(
    BuildContext context,
    WeekPlanDay sourceDay,
  ) async {
    final targetDays = weekPlanOverview.days
        .where((day) => day.planDate != sourceDay.planDate)
        .toList();
    if (targetDays.isEmpty) {
      return;
    }

    final selectedTargetDate = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Copy ${sourceDay.weekdayLabel} plan to'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: targetDays.map((day) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${day.weekdayLabel}  ${day.planDate}'),
                    subtitle: Text(day.hasPlan ? day.planName : 'No plan yet'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(day.planDate),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (selectedTargetDate == null || selectedTargetDate.isEmpty) {
      return;
    }

    await onCopyDay(sourceDay.planDate, selectedTargetDate);
  }

  Future<void> _openCopyDayToMultipleDialog(
    BuildContext context,
    WeekPlanDay sourceDay,
  ) async {
    final targetDays = weekPlanOverview.days
        .where((day) => day.planDate != sourceDay.planDate)
        .toList();
    if (targetDays.isEmpty) {
      return;
    }

    final selectedDates = <String>{};
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Copy ${sourceDay.weekdayLabel} to multiple days'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: targetDays.map((day) {
                      return CheckboxListTile(
                        value: selectedDates.contains(day.planDate),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${day.weekdayLabel}  ${day.planDate}'),
                        subtitle: Text(day.hasPlan ? day.planName : 'No plan yet'),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedDates.add(day.planDate);
                            } else {
                              selectedDates.remove(day.planDate);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton.tonal(
                  onPressed: selectedDates.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(true),
                  child: const Text('Copy'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedDates.isEmpty) {
      return;
    }

    await onCopyDayToDates(sourceDay.planDate, selectedDates.toList());
  }

  Future<void> _openQuickArrangeWeekDialog(BuildContext context) async {
    if (weekPlanOverview.days.isEmpty) {
      return;
    }

    final selectedTemplateByDate = <String, int>{};
    final clearDates = <String>{};

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Quick arrange this week'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: weekPlanOverview.days.map((day) {
                      final selectedTemplateId = selectedTemplateByDate[day.planDate];
                      final markedClear = clearDates.contains(day.planDate);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
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
                                    '${day.weekdayLabel}  ${day.planDate}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                if (day.today)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.mint.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'Today',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.hasPlan ? day.planName : 'No plan yet',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<int?>(
                              initialValue: markedClear ? null : selectedTemplateId,
                              decoration: const InputDecoration(
                                labelText: 'Template for this day',
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: -1,
                                  child: Text('Keep current plan'),
                                ),
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Clear this day'),
                                ),
                                ...weeklyTemplates.map((template) {
                                  return DropdownMenuItem<int?>(
                                    value: template.id,
                                    child: Text(template.templateName),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value == -1) {
                                    selectedTemplateByDate.remove(day.planDate);
                                    clearDates.remove(day.planDate);
                                  } else if (value == null) {
                                    selectedTemplateByDate.remove(day.planDate);
                                    clearDates.add(day.planDate);
                                  } else {
                                    selectedTemplateByDate[day.planDate] = value;
                                    clearDates.remove(day.planDate);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton.tonal(
                  onPressed:
                      selectedTemplateByDate.isEmpty && clearDates.isEmpty
                          ? null
                          : () => Navigator.of(context).pop(true),
                  child: const Text('Apply arrangement'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await onQuickArrangeWeek(
      Map<String, int>.from(selectedTemplateByDate),
      clearDates.toList(),
    );
  }

  Future<void> _confirmClearDay(
    BuildContext context,
    WeekPlanDay day,
  ) async {
    if (!day.hasPlan) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Clear ${day.weekdayLabel} plan'),
          content: Text(
            'Clear all tasks from ${day.planDate}? This will remove that day\'s plan content.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onClearDay(day.planDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 720;
            final actions = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () async {
                          await onSaveTemplate();
                        },
                  icon: const Icon(Icons.bookmark_add_rounded),
                  label: const Text('Save template'),
                ),
                OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () async {
                          await onEdit();
                        },
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('Edit today'),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Study plans', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    plan.planName,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  actions,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Study plans', style: textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        plan.planName,
                        style: textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                actions,
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          '${plan.completedCount}/${plan.totalCount} tasks finished  |  '
          '${plan.completedDurationLabel}/${plan.plannedDurationLabel}',
          style: textTheme.bodyMedium?.copyWith(
            color: lightStyle ? SurfacePalette.ink : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: plan.completionRatio,
            backgroundColor: lightStyle
                ? const Color(0xFFE6EBF0)
                : Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(
              lightStyle ? SurfacePalette.ink : AppColors.mint,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _WeekOverviewSection(
          lightStyle: lightStyle,
          overview: weekPlanOverview,
          weeklyTemplates: weeklyTemplates,
          isBusy: isBusy,
          onPreviousWeek: onPreviousWeek,
          onCurrentWeek: onCurrentWeek,
          onNextWeek: onNextWeek,
          onOpenPlanDate: onOpenPlanDate,
          onBatchApplyTemplates: () async {
            await _openBatchApplyTemplateDialog(context);
          },
          onQuickArrangeWeek: () async {
            await _openQuickArrangeWeekDialog(context);
          },
          onApplyTemplateToDate: (day) async {
            await _openApplyTemplateDialog(context, day);
          },
          onSaveTemplateForDay: onSaveTemplateForDay,
          onCopyDay: (day) async {
            await _openCopyDayDialog(context, day);
          },
          onCopyDayToMultipleDates: (day) async {
            await _openCopyDayToMultipleDialog(context, day);
          },
          onClearDay: (day) async {
            await _confirmClearDay(context, day);
          },
        ),
        const SizedBox(height: 16),
        _WeeklyTemplateSection(
          lightStyle: lightStyle,
          templates: weeklyTemplates,
          isBusy: isBusy,
          onApplyTemplate: onApplyTemplate,
          onDeleteTemplate: onDeleteTemplate,
          onPreviewTemplate: (template) async {
            await showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(template.templateName),
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 460,
                      maxHeight: 520,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Source: ${template.sourcePlanName}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${template.itemCount} tasks | ${template.plannedDurationLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          if (template.items.isEmpty)
                            Text(
                              'No tasks in this template yet.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            ...List.generate(template.items.length, (index) {
                              final item = template.items[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == template.items.length - 1 ? 0 : 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.hasSchedule
                                              ? AppColors.mint.withValues(alpha: 0.16)
                                              : Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          item.hasSchedule
                                              ? item.scheduleLabel
                                              : 'Flexible',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: AppColors.textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.durationLabel,
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        if (plan.hasScheduledItems) ...[
          const SizedBox(height: 16),
          _ScheduledOverview(
            plan: plan,
            lightStyle: lightStyle,
          ),
        ],
        const SizedBox(height: 16),
        if (!plan.hasItems)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightStyle
                  ? SurfacePalette.softSurface
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: lightStyle
                    ? SurfacePalette.border
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              'No tasks for today yet. Tap Edit today to create your first daily list.',
              style: textTheme.bodyMedium,
            ),
          )
        else
          ...List.generate(plan.items.length, (index) {
            final item = plan.items[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == plan.items.length - 1 ? 0 : 10,
              ),
              child: _PlanChecklistRow(
                item: item,
                isBusy: isBusy,
                lightStyle: lightStyle,
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

class _WeekOverviewSection extends StatelessWidget {
  const _WeekOverviewSection({
    required this.lightStyle,
    required this.overview,
    required this.weeklyTemplates,
    required this.isBusy,
    required this.onPreviousWeek,
    required this.onCurrentWeek,
    required this.onNextWeek,
    required this.onOpenPlanDate,
    required this.onBatchApplyTemplates,
    required this.onQuickArrangeWeek,
    required this.onApplyTemplateToDate,
    required this.onSaveTemplateForDay,
    required this.onCopyDay,
    required this.onCopyDayToMultipleDates,
    required this.onClearDay,
  });

  final bool lightStyle;
  final WeekPlanOverview overview;
  final List<WeeklyPlanTemplate> weeklyTemplates;
  final bool isBusy;
  final Future<void> Function() onPreviousWeek;
  final Future<void> Function() onCurrentWeek;
  final Future<void> Function() onNextWeek;
  final Future<void> Function(String planDate) onOpenPlanDate;
  final Future<void> Function() onBatchApplyTemplates;
  final Future<void> Function() onQuickArrangeWeek;
  final Future<void> Function(WeekPlanDay day) onApplyTemplateToDate;
  final Future<void> Function(String planDate) onSaveTemplateForDay;
  final Future<void> Function(WeekPlanDay day) onCopyDay;
  final Future<void> Function(WeekPlanDay day) onCopyDayToMultipleDates;
  final Future<void> Function(WeekPlanDay day) onClearDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightStyle
            ? SurfacePalette.softSurface
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lightStyle
              ? SurfacePalette.border
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onPreviousWeek();
                          },
                    child: const Text('Previous'),
                  ),
                  OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onCurrentWeek();
                          },
                    child: const Text('This week'),
                  ),
                  OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onNextWeek();
                          },
                    child: const Text('Next'),
                  ),
                  if (weeklyTemplates.isNotEmpty)
                    FilledButton.tonalIcon(
                      onPressed: isBusy
                          ? null
                          : () async {
                              await onBatchApplyTemplates();
                            },
                      icon: const Icon(Icons.calendar_view_week_rounded),
                      label: const Text('Apply to days'),
                    ),
                  FilledButton.tonalIcon(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onQuickArrangeWeek();
                          },
                    icon: const Icon(Icons.auto_awesome_mosaic_rounded),
                    label: const Text('Quick arrange'),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Weekly overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            overview.weekStartDate.isEmpty
                ? 'This week overview will appear after plans are loaded.'
                : '${overview.weekStartDate} to ${overview.weekEndDate}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          if (overview.days.isEmpty)
            Text(
              'No week data yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: overview.days.map((day) {
                return _WeekDayCard(
                  lightStyle: lightStyle,
                  day: day,
                  canApplyTemplate: weeklyTemplates.isNotEmpty,
                  isBusy: isBusy,
                  onOpenDay: () async {
                    await onOpenPlanDate(day.planDate);
                  },
                  onApplyTemplate: () async {
                    await onApplyTemplateToDate(day);
                  },
                  onSaveTemplate: () async {
                    await onSaveTemplateForDay(day.planDate);
                  },
                  onCopyDay: () async {
                    await onCopyDay(day);
                  },
                  onCopyDayToMultipleDates: () async {
                    await onCopyDayToMultipleDates(day);
                  },
                  onClearDay: () async {
                    await onClearDay(day);
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.lightStyle,
    required this.day,
    required this.canApplyTemplate,
    required this.isBusy,
    required this.onOpenDay,
    required this.onApplyTemplate,
    required this.onSaveTemplate,
    required this.onCopyDay,
    required this.onCopyDayToMultipleDates,
    required this.onClearDay,
  });

  final bool lightStyle;
  final WeekPlanDay day;
  final bool canApplyTemplate;
  final bool isBusy;
  final Future<void> Function() onOpenDay;
  final Future<void> Function() onApplyTemplate;
  final Future<void> Function() onSaveTemplate;
  final Future<void> Function() onCopyDay;
  final Future<void> Function() onCopyDayToMultipleDates;
  final Future<void> Function() onClearDay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: day.today
              ? (lightStyle
                    ? SurfacePalette.tintSurface
                    : AppColors.mint.withValues(alpha: 0.10))
              : (lightStyle
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: day.today
                ? (lightStyle
                    ? SurfacePalette.border
                    : AppColors.mint.withValues(alpha: 0.35))
                : (lightStyle
                    ? SurfacePalette.border
                    : Colors.white.withValues(alpha: 0.08)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    day.weekdayLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color:
                              lightStyle ? SurfacePalette.ink : AppColors.textPrimary,
                        ),
                  ),
                ),
                if (day.hasPlan)
                  PopupMenuButton<_WeekDayMenuAction>(
                    tooltip: 'More actions',
                    onSelected: (value) async {
                      switch (value) {
                        case _WeekDayMenuAction.copyToAnotherDay:
                          await onCopyDay();
                          break;
                        case _WeekDayMenuAction.copyToMultipleDays:
                          await onCopyDayToMultipleDates();
                          break;
                        case _WeekDayMenuAction.clearDay:
                          await onClearDay();
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<_WeekDayMenuAction>(
                          value: _WeekDayMenuAction.copyToAnotherDay,
                          child: Text('Copy to another day'),
                        ),
                        PopupMenuItem<_WeekDayMenuAction>(
                          value: _WeekDayMenuAction.copyToMultipleDays,
                          child: Text('Copy to multiple days'),
                        ),
                        PopupMenuItem<_WeekDayMenuAction>(
                          value: _WeekDayMenuAction.clearDay,
                          child: Text('Clear this day'),
                        ),
                      ];
                    },
                  ),
                if (day.today)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: lightStyle
                          ? SurfacePalette.tintSurface
                          : AppColors.mint.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: lightStyle
                          ? Border.all(color: SurfacePalette.border)
                          : null,
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              day.planDate,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Text(
              day.planName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        lightStyle ? SurfacePalette.ink : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              day.hasPlan
                  ? '${day.completedCount}/${day.totalCount} tasks | ${day.plannedDurationLabel}'
                  : 'No plan yet',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: day.completionRatio,
                backgroundColor: lightStyle
                    ? const Color(0xFFE6EBF0)
                    : Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(
                  lightStyle ? SurfacePalette.ink : AppColors.mint,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isBusy
                    ? null
                    : () async {
                        await onOpenDay();
                      },
                child: Text(day.hasPlan ? 'Open day' : 'Create day'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: !canApplyTemplate || isBusy
                    ? null
                    : () async {
                        await onApplyTemplate();
                      },
                child: const Text('Apply template'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: !day.hasPlan || isBusy
                    ? null
                    : () async {
                        await onSaveTemplate();
                      },
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Save as template'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyTemplateSection extends StatelessWidget {
  const _WeeklyTemplateSection({
    required this.lightStyle,
    required this.templates,
    required this.isBusy,
    required this.onApplyTemplate,
    required this.onDeleteTemplate,
    required this.onPreviewTemplate,
  });

  final bool lightStyle;
  final List<WeeklyPlanTemplate> templates;
  final bool isBusy;
  final Future<void> Function(int templateId) onApplyTemplate;
  final Future<void> Function(int templateId) onDeleteTemplate;
  final Future<void> Function(WeeklyPlanTemplate template) onPreviewTemplate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightStyle
            ? SurfacePalette.softSurface
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lightStyle
              ? SurfacePalette.border
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly templates',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Save today plan as a reusable weekly template, then apply it to today or any day in the weekly overview.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (templates.isEmpty)
            Text(
              'No weekly templates yet. Save the current short plan as your first reusable schedule.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...List.generate(templates.length, (index) {
              final template = templates[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == templates.length - 1 ? 0 : 10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightStyle
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: lightStyle
                        ? Border.all(color: SurfacePalette.border)
                        : null,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 520;
                      final detail = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.templateName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: lightStyle
                                      ? SurfacePalette.ink
                                      : AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${template.itemCount} tasks | ${template.plannedDurationLabel}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Source: ${template.sourcePlanName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      );
                      final action = FilledButton.tonal(
                        onPressed: isBusy
                            ? null
                            : () async {
                                await onApplyTemplate(template.id);
                              },
                        child: const Text('Apply to today'),
                      );
                      final previewAction = OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () async {
                                await onPreviewTemplate(template);
                              },
                        child: const Text('Preview'),
                      );
                      final deleteAction = IconButton(
                        tooltip: 'Delete template',
                        onPressed: isBusy
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete template'),
                                      content: Text(
                                        'Delete "${template.templateName}"? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton.tonal(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirmed == true) {
                                  await onDeleteTemplate(template.id);
                                }
                              },
                        icon: const Icon(Icons.delete_outline_rounded),
                      );

                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            detail,
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: previewAction,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: action,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                deleteAction,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: detail),
                          const SizedBox(width: 12),
                          previewAction,
                          const SizedBox(width: 8),
                          deleteAction,
                          const SizedBox(width: 8),
                          action,
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ScheduledOverview extends StatelessWidget {
  const _ScheduledOverview({
    required this.plan,
    required this.lightStyle,
  });

  final TodayPlan plan;
  final bool lightStyle;

  @override
  Widget build(BuildContext context) {
    final scheduledItems = plan.scheduledItems;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightStyle
            ? SurfacePalette.softSurface
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: lightStyle
              ? SurfacePalette.border
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today timeline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...List.generate(scheduledItems.length, (index) {
            final item = scheduledItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == scheduledItems.length - 1 ? 0 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 118,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: item.completed
                          ? (lightStyle
                              ? SurfacePalette.tintSurface
                              : AppColors.mint.withValues(alpha: 0.18))
                          : (lightStyle
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(14),
                      border: lightStyle
                          ? Border.all(color: SurfacePalette.border)
                          : null,
                    ),
                    child: Text(
                      item.scheduleLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                lightStyle ? SurfacePalette.ink : AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: lightStyle
                                      ? SurfacePalette.ink
                                      : AppColors.textPrimary,
                                  decoration: item.completed
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.durationLabel,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PlanChecklistRow extends StatelessWidget {
  const _PlanChecklistRow({
    required this.item,
    required this.isBusy,
    required this.lightStyle,
    required this.onChanged,
  });

  final TodayPlanItem item;
  final bool isBusy;
  final bool lightStyle;
  final Future<void> Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: lightStyle
            ? SurfacePalette.softSurface
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: lightStyle ? Border.all(color: SurfacePalette.border) : null,
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
                      color: lightStyle ? SurfacePalette.ink : AppColors.textPrimary,
                      decoration: item.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (item.plannedMinutes > 0 || item.hasSchedule) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.hasSchedule
                          ? '${item.scheduleLabel}  |  ${item.durationLabel}'
                          : 'Planned ${item.plannedMinutes} min',
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

enum _WeekDayMenuAction {
  copyToAnotherDay,
  copyToMultipleDays,
  clearDay,
}
