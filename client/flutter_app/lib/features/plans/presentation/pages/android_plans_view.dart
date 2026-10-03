import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:innocence_flutter/app/app_language.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/themed_dialog.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/domain/models/weekly_plan_template.dart';
import '../widgets/annual_charge_span.dart';
import '../widgets/today_plan_editor_dialog.dart';

/// Uses the current session's callbacks; this view never opens a separate store.
class AndroidPlanActions {
  const AndroidPlanActions({
    required this.loadMonth,
    required this.loadYear,
    required this.loadDate,
    required this.saveDate,
    required this.saveArchive,
    required this.deleteArchive,
    required this.applyArchive,
    required this.saveAnnual,
    required this.deleteAnnual,
  });

  final Future<void> Function(String month) loadMonth;
  final Future<void> Function(int year) loadYear;
  final Future<TodayPlan?> Function(String date) loadDate;
  final Future<bool> Function(TodayPlan plan) saveDate;
  final Future<bool> Function(String name, TodayPlan plan) saveArchive;
  final Future<void> Function(int id) deleteArchive;
  final Future<void> Function(int id, List<String> dates,
      {required PlanApplyStrategy strategy}) applyArchive;
  final Future<bool> Function(AnnualPlanSegment segment) saveAnnual;
  final Future<void> Function(AnnualPlanSegment segment) deleteAnnual;
}

enum _Horizon { day, month, year }

class AndroidPlansView extends StatefulWidget {
  const AndroidPlansView({
    super.key,
    required this.language,
    required this.month,
    required this.annual,
    required this.archives,
    required this.todayPlan,
    required this.actions,
    required this.isBusy,
    required this.isOffline,
    required this.dayContent,
    required this.bannerMessage,
    required this.onClearBanner,
  });

  final AppLanguage language;
  final MonthPlanOverview month;
  final AnnualPlanOverview annual;
  final List<WeeklyPlanTemplate> archives;
  final TodayPlan todayPlan;
  final AndroidPlanActions actions;
  final bool isBusy;
  final bool isOffline;
  final List<Widget> Function() dayContent;
  final String? bannerMessage;
  final VoidCallback onClearBanner;

  @override
  State<AndroidPlansView> createState() => _AndroidPlansViewState();
}

class _AndroidPlansViewState extends State<AndroidPlansView> {
  _Horizon _horizon = _Horizon.day;
  final _scroll = ScrollController();
  final _monthOffset = ValueNotifier<double>(0);
  final _selectedDates = <String>{};
  bool _multiSelect = false;
  bool _working = false;
  late String _selectedDate;
  int? _filterMonth;
  String? _error;

  bool get _busy => widget.isBusy || _working;
  bool get _zh => widget.language.isChinese;
  String _t(String zh, String en) => _zh ? zh : en;
  DateTime get _monthStart => DateTime.parse('${widget.month.month}-01');
  static String _date(DateTime date) =>
      '${MonthPlanOverview.formatMonth(date)}-${date.day.toString().padLeft(2, '0')}';

  String _initialDate() {
    final now = DateTime.now();
    return widget.month.month == MonthPlanOverview.formatMonth(now)
        ? _date(now)
        : '${widget.month.month}-01';
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _initialDate();
  }

  @override
  void didUpdateWidget(covariant AndroidPlansView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month.month != widget.month.month) {
      _selectedDate = _initialDate();
      _selectedDates.clear();
    }
    if (oldWidget.annual.year != widget.annual.year) _filterMonth = null;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _monthOffset.dispose();
    super.dispose();
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = _t('操作未完成，请重试。', 'Operation failed. Please retry.'));
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _switch(_Horizon horizon) async {
    if (_busy || horizon == _horizon) return;
    setState(() => _horizon = horizon);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    await _reload();
  }

  Future<void> _reload() => _perform(() async {
        if (_horizon == _Horizon.month) {
          await widget.actions.loadMonth(widget.month.month);
        } else if (_horizon == _Horizon.year) {
          await widget.actions.loadYear(widget.annual.year);
        }
      });

  Future<bool> _confirm(String title, String detail) async =>
      await showThemedDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(detail),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(_t('取消', 'Cancel'))),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(_t('确认', 'Confirm'))),
          ],
        ),
      ) ==
      true;

  Future<void> _editDate() => _perform(() async {
        final plan = await widget.actions.loadDate(_selectedDate);
        if (!mounted) return;
        if (plan == null) {
          setState(() => _error =
              _t('日期计划加载失败，请重试。', 'Could not load this day. Please retry.'));
          if (_scroll.hasClients) _scroll.jumpTo(0);
          return;
        }
        await showThemedDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => TodayPlanEditorDialog(
            initialPlan: plan,
            onSaveResult: widget.actions.saveDate,
            onSaveAsArchive: widget.actions.saveArchive,
          ),
        );
      });

  Future<void> _editArchive({WeeklyPlanTemplate? archive, TodayPlan? source}) =>
      _perform(() async {
        await showThemedDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => TodayPlanEditorDialog(
            initialPlan:
                (source ?? TodayPlan.empty(widget.todayPlan.planDate)).copyWith(
              planName: archive?.templateName ?? '',
              items: archive?.items ?? source?.items ?? const [],
            ),
            archiveMode: true,
            lockPlanName: archive != null,
            onSaveArchive: (plan) =>
                widget.actions.saveArchive(plan.planName, plan),
          ),
        );
      });

  Future<void> _apply(WeeklyPlanTemplate archive) => _perform(() async {
        final dates = (_multiSelect ? _selectedDates.toList() : [_selectedDate])
          ..sort();
        if (dates.isEmpty) {
          setState(() =>
              _error = _t('请先在月历选择日期。', 'Select dates in the calendar first.'));
          return;
        }
        final conflicts =
            dates.where((date) => widget.month.dayFor(date).hasPlan).length;
        final strategy = await showThemedDialog<PlanApplyStrategy>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_t('套用任务存档', 'Apply task archive')),
            content: SingleChildScrollView(
                child: Text(_t(
              '${archive.templateName}\n将套用到 ${dates.length} 天，其中 $conflicts 天已有计划。\n${dates.join('、')}',
              '${archive.templateName}\nApply to ${dates.length} days; $conflicts already have plans.\n${dates.join(', ')}',
            ))),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(_t('取消', 'Cancel'))),
              TextButton(
                  onPressed: () =>
                      Navigator.pop(context, PlanApplyStrategy.skip),
                  child: Text(_t('跳过已有计划', 'Skip existing'))),
              FilledButton(
                  onPressed: () =>
                      Navigator.pop(context, PlanApplyStrategy.overwrite),
                  child: Text(_t('覆盖并套用', 'Overwrite and apply'))),
            ],
          ),
        );
        if (strategy == null || !mounted) return;
        // Keep the selection after failures and partial server responses.
        await widget.actions
            .applyArchive(archive.id, dates, strategy: strategy);
      });

  Future<void> _editAnnual([AnnualPlanSegment? initial]) => _perform(() async {
        await showThemedDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => _AnnualEditor(
            year: widget.annual.year,
            initial: initial,
            initialMonth: _filterMonth ?? 1,
            isChinese: _zh,
            onSave: widget.actions.saveAnnual,
          ),
        );
      });

  Future<void> _saveSegment(AnnualPlanSegment segment) => _perform(() async {
        final saved = await widget.actions.saveAnnual(segment);
        if (!saved && mounted) {
          setState(() => _error =
              _t('年度任务未保存，请重试。', 'Annual task not saved. Please retry.'));
        }
      });

  Widget _panel(Widget child, {Key? key}) => Padding(
        key: key,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: GlassPanel(
            padding: const EdgeInsets.all(16),
            child: Material(type: MaterialType.transparency, child: child)),
      );

  Widget _range({required String title, required bool year}) => _panel(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          Row(children: [
            IconButton(
                key: ValueKey(
                    year ? 'android-previous-year' : 'android-previous-month'),
                tooltip: _t(year ? '上一年' : '上个月',
                    year ? 'Previous year' : 'Previous month'),
                onPressed: _busy ? null : () => _shift(-1, year),
                icon: const Icon(Icons.chevron_left)),
            Expanded(
                child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => _perform(() => year
                            ? widget.actions.loadYear(DateTime.now().year)
                            : widget.actions.loadMonth(
                                MonthPlanOverview.formatMonth(DateTime.now()))),
                    child: Text(_t(year ? '今年' : '本月',
                        year ? 'This year' : 'This month')))),
            IconButton(
                key:
                    ValueKey(year ? 'android-next-year' : 'android-next-month'),
                tooltip:
                    _t(year ? '下一年' : '下个月', year ? 'Next year' : 'Next month'),
                onPressed: _busy ? null : () => _shift(1, year),
                icon: const Icon(Icons.chevron_right)),
          ]),
          if (!year)
            Text(_t(
                '${widget.month.plannedDayCount} 个计划日 · ${widget.month.completedTaskCount}/${widget.month.totalTaskCount} 项完成',
                '${widget.month.plannedDayCount} planned days · ${widget.month.completedTaskCount}/${widget.month.totalTaskCount} tasks complete')),
        ],
      ));

  Future<void> _shift(int delta, bool year) => _perform(() => year
      ? widget.actions.loadYear(widget.annual.year + delta)
      : widget.actions.loadMonth(MonthPlanOverview.formatMonth(
          DateTime(_monthStart.year, _monthStart.month + delta))));

  Widget _calendar() {
    final start = _monthStart;
    final count = DateTime(start.year, start.month + 1, 0).day;
    final leading = start.weekday - 1;
    final cells = ((leading + count + 6) ~/ 7) * 7;
    final colors = Theme.of(context).colorScheme;
    return _panel(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
                label: Text(_t('多选日期', 'Select multiple')),
                selected: _multiSelect,
                onSelected: _busy
                    ? null
                    : (value) => setState(() {
                          _multiSelect = value;
                          _selectedDates.clear();
                        })),
            if (_multiSelect)
              Text(_t('已选 ${_selectedDates.length} 天',
                  '${_selectedDates.length} selected')),
            if (_selectedDates.isNotEmpty)
              TextButton(
                  onPressed:
                      _busy ? null : () => setState(_selectedDates.clear),
                  child: Text(_t('清除选择', 'Clear selection'))),
          ]),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, constraints) {
        // A horizontal viewport preserves 48dp targets at 320dp or large fonts.
        final scaledDateFont = MediaQuery.textScalerOf(context).scale(16);
        final width = math.max(
            constraints.maxWidth, 7.0 * math.max(48.0, scaledDateFont * 2 + 8));
        final height = math.max(52.0, scaledDateFont + 24);
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
                width: width,
                child: Column(children: [
                  Row(children: [
                    for (final label in (_zh
                        ? ['一', '二', '三', '四', '五', '六', '日']
                        : ['M', 'T', 'W', 'T', 'F', 'S', 'S']))
                      Expanded(child: Text(label, textAlign: TextAlign.center))
                  ]),
                  const SizedBox(height: 8),
                  GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7, mainAxisExtent: height),
                      itemCount: cells,
                      itemBuilder: (context, index) {
                        final number = index - leading + 1;
                        if (number < 1 || number > count) {
                          return const SizedBox.shrink();
                        }
                        final date =
                            _date(DateTime(start.year, start.month, number));
                        final day = widget.month.dayFor(date);
                        final selected = _multiSelect
                            ? _selectedDates.contains(date)
                            : date == _selectedDate;
                        final today = date == _date(DateTime.now());
                        return Semantics(
                          selected: selected,
                          label: _t('$date，${day.totalCount} 项任务',
                              '$date, ${day.totalCount} tasks'),
                          child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                key: ValueKey('android-calendar-$date'),
                                borderRadius: BorderRadius.circular(12),
                                onTap: _busy
                                    ? null
                                    : () => setState(() {
                                          _selectedDate = date;
                                          if (_multiSelect &&
                                              !_selectedDates.remove(date)) {
                                            _selectedDates.add(date);
                                          }
                                        }),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? colors.primary
                                          : colors.surface
                                              .withValues(alpha: .5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: today
                                              ? colors.primary
                                              : Colors.transparent),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('$number',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  height: 1.2,
                                                  color: selected
                                                      ? colors.onPrimary
                                                      : colors.onSurface)),
                                          const SizedBox(height: 3),
                                          Container(
                                              width: 5,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: day.hasPlan
                                                      ? (selected
                                                          ? colors.onPrimary
                                                          : colors.primary)
                                                      : Colors.transparent)),
                                        ]),
                                  ),
                                ),
                              )),
                        );
                      }),
                ])));
      }),
      const SizedBox(height: 10),
      Text(_t('点选日期查看详情；多选后可从存档架批量套用。',
          'Tap a date for details; select multiple dates to apply an archive.')),
    ]));
  }

  Widget _dateDetail() {
    final day = widget.month.dayFor(_selectedDate);
    return _panel(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_selectedDate, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(day.hasPlan
          ? '${day.planName} · ${day.completedCount}/${day.totalCount} · ${day.plannedDurationLabel}'
          : _t('这一天还没有计划', 'No plan for this day')),
      const SizedBox(height: 10),
      FilledButton.icon(
          key: const ValueKey('android-edit-selected-date'),
          onPressed: _busy ? null : _editDate,
          icon: const Icon(Icons.edit_calendar_outlined),
          label: Text(_t('查看／编辑日期计划', 'View / edit this day'))),
    ]));
  }

  List<Widget> _archives() => [
        _panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_t('任务存档架', 'Task archives'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_t('存档不绑定日期，可重复套用；同名保存更新内容。',
              'Archives are reusable and date-free. Saving the same name updates its contents.')),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              key: const ValueKey('android-create-archive'),
              onPressed: _busy ? null : () => _editArchive(),
              icon: const Icon(Icons.add_box_outlined),
              label: Text(_t('新建任务存档', 'Create task archive'))),
          if (widget.archives.isEmpty)
            Text(_t('还没有任务存档', 'No task archives yet')),
        ])),
        for (final archive in widget.archives)
          _panel(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(archive.templateName,
                style: Theme.of(context).textTheme.titleMedium),
            Text(_t(
                '${archive.itemCount} 项任务 · ${archive.plannedDurationLabel}',
                '${archive.itemCount} tasks · ${archive.plannedDurationLabel}')),
            Wrap(spacing: 8, children: [
              FilledButton(
                  key: ValueKey('android-apply-archive-${archive.id}'),
                  onPressed: _busy ? null : () => _apply(archive),
                  child: Text(_t('套用到所选日期', 'Apply to selected dates'))),
              TextButton(
                  onPressed:
                      _busy ? null : () => _editArchive(archive: archive),
                  child: Text(_t('编辑', 'Edit'))),
              TextButton(
                  onPressed: _busy
                      ? null
                      : () => _perform(() async {
                            if (await _confirm(
                                    _t('删除任务存档？', 'Delete task archive?'),
                                    archive.templateName) &&
                                mounted) {
                              await widget.actions.deleteArchive(archive.id);
                            }
                          }),
                  child: Text(_t('删除', 'Delete'))),
            ]),
          ])),
      ];

  Widget _annualCard(AnnualPlanSegment segment) {
    final color = annualTaskColors
        .firstWhere((option) => option.key == segment.colorKey,
            orElse: () => annualTaskColors.first)
        .color;
    final theme = Theme.of(context);
    return _panel(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(segment.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(_t(
              '${segment.startMonth}–${segment.endMonth} 月 · ${segment.progressPercent}%${segment.isCompleted ? ' · 已完成' : ''}',
              'Months ${segment.startMonth}–${segment.endMonth} · ${segment.progressPercent}%${segment.isCompleted ? ' · Completed' : ''}')),
          const SizedBox(height: 12),
          _LinkedMonths(
              offset: _monthOffset,
              builder: (width) => Semantics(
                    label: _t(
                        '${segment.title}，${segment.startMonth}至${segment.endMonth}月，进度${segment.progressPercent}%',
                        '${segment.title}, months ${segment.startMonth} to ${segment.endMonth}, ${segment.progressPercent}%'),
                    child: AnnualChargeSpan(
                        key: ValueKey('android-charge-${segment.id}'),
                        color: color,
                        trackColor: theme.colorScheme.outlineVariant,
                        surfaceColor: theme.colorScheme.surface,
                        glass: theme
                                .extension<AppVisualThemeMarker>()
                                ?.visualTheme ==
                            AppVisualTheme.glass,
                        startMonth: segment.startMonth,
                        endMonth: segment.endMonth,
                        progressPercent: segment.progressPercent),
                  )),
          const SizedBox(height: 12),
          if (segment.note.isNotEmpty) Text(segment.note),
          Wrap(spacing: 8, children: [
            for (final step in [10, 5, 1])
              Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton(
                    key: ValueKey('android-progress-minus-${segment.id}-$step'),
                    onPressed: _busy || segment.progressPercent == 0
                        ? null
                        : () => _saveSegment(segment.adjustProgress(-step)),
                    child: Text('−$step%')),
                const SizedBox(width: 4),
                OutlinedButton(
                    key: ValueKey('android-progress-plus-${segment.id}-$step'),
                    onPressed: _busy || segment.isCompleted
                        ? null
                        : () => _saveSegment(segment.adjustProgress(step)),
                    child: Text('+$step%')),
              ]),
          ]),
          Wrap(spacing: 8, children: [
            FilledButton(
                key: ValueKey('android-complete-${segment.id}'),
                onPressed: _busy || segment.isCompleted
                    ? null
                    : () =>
                        _saveSegment(segment.copyWith(progressPercent: 100)),
                child: Text(_t('完成任务', 'Complete task'))),
            TextButton(
                key: ValueKey('android-edit-annual-${segment.id}'),
                onPressed: _busy ? null : () => _editAnnual(segment),
                child: Text(_t('编辑', 'Edit'))),
            TextButton(
                onPressed: _busy
                    ? null
                    : () => _perform(() async {
                          if (await _confirm(
                                  _t('删除年度任务？', 'Delete annual task?'),
                                  segment.title) &&
                              mounted) {
                            await widget.actions.deleteAnnual(segment);
                          }
                        }),
                child: Text(_t('删除', 'Delete'))),
          ]),
          Text(_t(
              '子任务 ${segment.completedSubtaskCount}/${segment.subtasks.length} · 独立于任务进度',
              'Subtasks ${segment.completedSubtaskCount}/${segment.subtasks.length} · independent of task progress')),
          for (final entry in segment.subtasks.indexed)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              key: ValueKey('android-subtask-${segment.id}-${entry.$1}'),
              value: entry.$2.completed,
              title: Text(entry.$2.title),
              subtitle: entry.$2.detail.isEmpty ? null : Text(entry.$2.detail),
              onChanged: _busy
                  ? null
                  : (value) => _saveSegment(segment.copyWith(subtasks: [
                        for (final item in segment.subtasks.indexed)
                          item.$1 == entry.$1
                              ? item.$2.copyWith(completed: value ?? false)
                              : item.$2,
                      ])),
            ),
          TextButton.icon(
              onPressed: _busy ? null : () => _editAnnual(segment),
              icon: const Icon(Icons.checklist),
              label: Text(_t('添加／编辑子任务', 'Add / edit subtasks'))),
        ]),
        key: ValueKey('android-annual-card-${segment.id}'));
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: [
            SizedBox(
                width: double.infinity,
                child: SegmentedButton<_Horizon>(
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 8))),
                  selected: {_horizon},
                  segments: [
                    ButtonSegment(
                        value: _Horizon.day,
                        label: Text(_t('今日', 'Day'),
                            maxLines: 1, softWrap: false)),
                    ButtonSegment(
                        value: _Horizon.month,
                        label: Text(_t('月计划', 'Month'),
                            maxLines: 1, softWrap: false)),
                    ButtonSegment(
                        value: _Horizon.year,
                        label: Text(_t('年度', 'Year'),
                            maxLines: 1, softWrap: false)),
                  ],
                  onSelectionChanged:
                      _busy ? null : (value) => _switch(value.single),
                )),
            if (_horizon == _Horizon.year) ...[
              Row(children: [
                TextButton(
                    key: const ValueKey('android-all-months'),
                    onPressed: () => setState(() => _filterMonth = null),
                    child: Text(_t('全年', 'All year'))),
                Expanded(
                    child: Text(
                        _filterMonth == null
                            ? _t('左右滑动月份刻度', 'Scroll the month ruler')
                            : _t('筛选 $_filterMonth 月', 'Month $_filterMonth'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
              _LinkedMonths(
                  offset: _monthOffset,
                  builder: (width) {
                    final grid = AnnualMonthGrid(width);
                    return SizedBox(
                        height: 48,
                        child: Row(children: [
                          for (var month = 1; month <= 12; month++) ...[
                            if (month > 1)
                              const SizedBox(width: AnnualMonthGrid.gap),
                            SizedBox(
                                width: grid.cellWidth,
                                child: Semantics(
                                    selected: month == _filterMonth,
                                    child: TextButton(
                                        key: ValueKey(
                                            'android-filter-month-$month'),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            backgroundColor:
                                                month == _filterMonth
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                    : null),
                                        onPressed: () => setState(() =>
                                            _filterMonth = _filterMonth == month
                                                ? null
                                                : month),
                                        child: Text('$month')))),
                          ]
                        ]));
                  }),
            ],
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final segments = widget.annual.segments
        .where((task) =>
            _filterMonth == null ||
            (_filterMonth! >= task.startMonth &&
                _filterMonth! <= task.endMonth))
        .toList();
    final headerHeight =
        math.max(72.0, MediaQuery.textScalerOf(context).scale(14) + 52) +
            (_horizon == _Horizon.year ? 100 : 0);
    return CustomScrollView(
        key: const ValueKey('android-plans-content'),
        controller: _scroll,
        slivers: [
          SliverPersistentHeader(
              pinned: true,
              delegate: _PlanHeader(height: headerHeight, child: _header())),
          if (widget.isBusy)
            const SliverToBoxAdapter(child: LinearProgressIndicator()),
          SliverPadding(
              padding: const EdgeInsets.only(top: 12, bottom: 32),
              sliver: SliverList.list(children: [
                if (widget.bannerMessage != null)
                  _panel(ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.bannerMessage!),
                      trailing: IconButton(
                          onPressed: widget.onClearBanner,
                          tooltip: _t('关闭提示', 'Dismiss notice'),
                          icon: const Icon(Icons.close)))),
                if (_error != null)
                  _panel(Column(children: [
                    Text(_error!),
                    TextButton(
                        onPressed: _busy ? null : _reload,
                        child: Text(_t('重试', 'Retry')))
                  ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(widget.isOffline
                        ? _t('仅本机 · 数据尚未绑定账号',
                            'On device only · data is not linked to an account')
                        : _t('当前账号的计划', 'Plans for the current account'))),
                if (_horizon == _Horizon.day) ...[
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.dayContent())),
                  _panel(OutlinedButton.icon(
                      key: const ValueKey('android-save-today-archive'),
                      onPressed: _busy || !widget.todayPlan.hasItems
                          ? null
                          : () => _editArchive(source: widget.todayPlan),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label:
                          Text(_t('将今日安排保存为存档', 'Save today as an archive')))),
                ],
                if (_horizon == _Horizon.month) ...[
                  _range(
                      title: _t('${_monthStart.year} 年 ${_monthStart.month} 月',
                          widget.month.month),
                      year: false),
                  _calendar(),
                  _dateDetail(),
                  ..._archives(),
                ],
                if (_horizon == _Horizon.year) ...[
                  _range(
                      title: _t('${widget.annual.year} 年度任务',
                          '${widget.annual.year} annual tasks'),
                      year: true),
                  _panel(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('外框表示月份跨度，框内填充表示进度；年度任务独立于月计划。',
                            'The frame marks the month span; its fill shows progress. Annual tasks are independent of monthly plans.')),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                            key: const ValueKey('android-create-annual'),
                            onPressed: _busy ? null : () => _editAnnual(),
                            icon: const Icon(Icons.add),
                            label: Text(_t('新建年度任务', 'Create annual task'))),
                      ])),
                  if (segments.isEmpty)
                    _panel(Text(
                        _t('当前范围还没有年度任务', 'No annual tasks in this range'))),
                  for (final segment in segments) _annualCard(segment),
                ],
              ])),
        ]);
  }
}

class _PlanHeader extends SliverPersistentHeaderDelegate {
  const _PlanHeader({required this.height, required this.child});
  final double height;
  final Widget child;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);
  @override
  bool shouldRebuild(covariant _PlanHeader oldDelegate) =>
      oldDelegate.height != height || oldDelegate.child != child;
}

/// All cards and the sticky ruler retain the same 48dp month geometry and offset.
class _LinkedMonths extends StatefulWidget {
  const _LinkedMonths({required this.offset, required this.builder});
  final ValueNotifier<double> offset;
  final Widget Function(double width) builder;
  @override
  State<_LinkedMonths> createState() => _LinkedMonthsState();
}

class _LinkedMonthsState extends State<_LinkedMonths> {
  late final ScrollController _controller;
  bool _syncing = false;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: widget.offset.value);
    widget.offset.addListener(_sync);
  }

  void _sync() {
    if (!_controller.hasClients || _syncing) return;
    final target =
        widget.offset.value.clamp(0.0, _controller.position.maxScrollExtent);
    if ((_controller.offset - target).abs() < .1) return;
    _syncing = true;
    _controller.jumpTo(target);
    _syncing = false;
  }

  @override
  void dispose() {
    widget.offset.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final width = math.max(
            constraints.maxWidth, 12 * 48.0 + 11 * AnnualMonthGrid.gap);
        return NotificationListener<ScrollNotification>(
            onNotification: (notice) {
              if (notice.depth == 0 &&
                  notice is ScrollUpdateNotification &&
                  !_syncing) {
                _syncing = true;
                widget.offset.value = notice.metrics.pixels
                    .clamp(0.0, notice.metrics.maxScrollExtent);
                _syncing = false;
              }
              return false;
            },
            child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: SizedBox(width: width, child: widget.builder(width))));
      });
}

class AnnualTaskColor {
  const AnnualTaskColor(this.key, this.zh, this.en, this.color);
  final String key, zh, en;
  final Color color;
}

const annualTaskColors = [
  AnnualTaskColor('accent', '电光紫', 'Electric violet', Color(0xFF7657F7)),
  AnnualTaskColor('warm', '跃动橙', 'Vivid orange', Color(0xFFF46A25)),
  AnnualTaskColor('cool', '亮蓝', 'Bright blue', Color(0xFF2675E8)),
  AnnualTaskColor('neutral', '翠绿', 'Emerald green', Color(0xFF0BAD70)),
  AnnualTaskColor('coral', '珊瑚红', 'Coral red', Color(0xFFF3445A)),
  AnnualTaskColor('gold', '鎏金黄', 'Golden yellow', Color(0xFFE6A300)),
  AnnualTaskColor('cyan', '湖水青', 'Clear cyan', Color(0xFF00A8BE)),
];

class _AnnualEditor extends StatefulWidget {
  const _AnnualEditor(
      {required this.year,
      this.initial,
      required this.initialMonth,
      required this.isChinese,
      required this.onSave});
  final int year, initialMonth;
  final AnnualPlanSegment? initial;
  final bool isChinese;
  final Future<bool> Function(AnnualPlanSegment segment) onSave;
  @override
  State<_AnnualEditor> createState() => _AnnualEditorState();
}

class _AnnualEditorState extends State<_AnnualEditor> {
  late final TextEditingController _title, _note, _progress;
  late int _start, _end;
  late String _color;
  late final List<AnnualPlanSubtask> _subtasks;
  bool _saving = false;
  String? _error;
  String _t(String zh, String en) => widget.isChinese ? zh : en;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _note = TextEditingController(text: widget.initial?.note ?? '');
    _progress =
        TextEditingController(text: '${widget.initial?.progressPercent ?? 0}');
    _start = widget.initial?.startMonth ?? widget.initialMonth;
    _end = widget.initial?.endMonth ?? _start;
    _color = widget.initial?.colorKey ?? 'accent';
    _subtasks = [...?widget.initial?.subtasks];
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final progress = int.tryParse(_progress.text.trim());
    if (_title.text.trim().isEmpty ||
        progress == null ||
        progress < 0 ||
        progress > 100 ||
        _end < _start) {
      setState(() => _error = _t('请输入标题、有效月份跨度和 0–100 的整数进度。',
          'Enter a title, valid month span, and integer progress from 0 to 100.'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final initial = widget.initial;
    final segment = AnnualPlanSegment(
        id: initial?.id ?? '',
        clientEntityId: initial?.clientEntityId ?? '',
        year: widget.year,
        title: _title.text.trim(),
        startMonth: _start,
        endMonth: _end,
        colorKey: _color,
        sortOrder: initial?.sortOrder ?? 0,
        note: _note.text.trim(),
        progressPercent: progress,
        revision: initial?.revision ?? 0,
        updateTime: initial?.updateTime ?? '',
        subtasks: [
          for (final entry in _subtasks.indexed)
            entry.$2.copyWith(sortOrder: entry.$1)
        ]);
    try {
      final saved = await widget.onSave(segment);
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
        return;
      }
      setState(() => _error = _t(
          '保存失败，草稿已保留，请重试。', 'Save failed. Your draft is kept; please retry.'));
    } catch (_) {
      if (mounted) {
        setState(() => _error = _t('保存失败，草稿已保留，请重试。',
            'Save failed. Your draft is kept; please retry.'));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _subtask([int? index]) async {
    final result = await showThemedDialog<AnnualPlanSubtask>(
        context: context,
        builder: (_) => _SubtaskEditor(
            isChinese: widget.isChinese,
            initial: index == null ? null : _subtasks[index]));
    if (result != null && mounted) {
      setState(() {
        if (index == null) {
          _subtasks.add(result);
        } else {
          _subtasks[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 560,
          height: math.min(720, MediaQuery.sizeOf(context).height * .9),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                    _t(
                        widget.initial == null ? '新建年度任务' : '编辑年度任务',
                        widget.initial == null
                            ? 'Create annual task'
                            : 'Edit annual task'),
                    style: Theme.of(context).textTheme.titleLarge)),
            Expanded(
                child: SingleChildScrollView(
                    key: const ValueKey('android-annual-editor-scroll'),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                              key: const ValueKey('android-annual-title'),
                              controller: _title,
                              enabled: !_saving,
                              decoration: InputDecoration(
                                  labelText: _t('任务标题', 'Task title'))),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                              key: ValueKey('android-annual-start-$_start'),
                              initialValue: _start,
                              decoration: InputDecoration(
                                  labelText: _t('开始月份', 'Start month')),
                              items: [
                                for (var m = 1; m <= 12; m++)
                                  DropdownMenuItem(
                                      value: m,
                                      child: Text(_t('$m 月', 'Month $m')))
                              ],
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _start = v!)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                              key: ValueKey('android-annual-end-$_end'),
                              initialValue: _end,
                              decoration: InputDecoration(
                                  labelText: _t('结束月份', 'End month')),
                              items: [
                                for (var m = 1; m <= 12; m++)
                                  DropdownMenuItem(
                                      value: m,
                                      child: Text(_t('$m 月', 'Month $m')))
                              ],
                              onChanged: _saving
                                  ? null
                                  : (v) => setState(() => _end = v!)),
                          const SizedBox(height: 16),
                          TextField(
                              key: const ValueKey('android-annual-progress'),
                              controller: _progress,
                              enabled: !_saving,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: _t('任务进度（0–100%）',
                                      'Task progress (0–100%)'))),
                          const SizedBox(height: 16),
                          Wrap(spacing: 8, runSpacing: 4, children: [
                            for (final option in annualTaskColors)
                              ChoiceChip(
                                  key: ValueKey(
                                      'android-annual-color-${option.key}'),
                                  label: Text(
                                      widget.isChinese ? option.zh : option.en),
                                  avatar: CircleAvatar(
                                      backgroundColor: option.color, radius: 7),
                                  selected: option.key == _color,
                                  onSelected: _saving
                                      ? null
                                      : (_) =>
                                          setState(() => _color = option.key))
                          ]),
                          const SizedBox(height: 16),
                          TextField(
                              controller: _note,
                              enabled: !_saving,
                              minLines: 2,
                              maxLines: 4,
                              decoration: InputDecoration(
                                  labelText: _t('说明', 'Notes'))),
                          const SizedBox(height: 16),
                          Text(_t('子任务（完成状态独立）',
                              'Subtasks (independent completion)')),
                          for (final entry in _subtasks.indexed)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                      contentPadding: EdgeInsets.zero,
                                      value: entry.$2.completed,
                                      title: Text(entry.$2.title),
                                      subtitle: entry.$2.detail.isEmpty
                                          ? null
                                          : Text(entry.$2.detail),
                                      onChanged: _saving
                                          ? null
                                          : (v) => setState(() =>
                                              _subtasks[entry.$1] = entry.$2
                                                  .copyWith(
                                                      completed: v ?? false))),
                                  Wrap(children: [
                                    TextButton(
                                        onPressed: _saving
                                            ? null
                                            : () => _subtask(entry.$1),
                                        child:
                                            Text(_t('编辑子任务', 'Edit subtask'))),
                                    TextButton(
                                        onPressed: _saving
                                            ? null
                                            : () => setState(() =>
                                                _subtasks.removeAt(entry.$1)),
                                        child: Text(
                                            _t('删除子任务', 'Delete subtask'))),
                                  ]),
                                ]),
                          TextButton.icon(
                              key: const ValueKey('android-add-subtask'),
                              onPressed: _saving ? null : _subtask,
                              icon: const Icon(Icons.add),
                              label: Text(_t('添加子任务', 'Add subtask'))),
                          const SizedBox(height: 12),
                        ]))),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_error != null)
                    Semantics(
                        liveRegion: true,
                        child: Text(_error!,
                            key: const ValueKey('android-annual-error'),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                  OverflowBar(spacing: 8, children: [
                    TextButton(
                        onPressed:
                            _saving ? null : () => Navigator.pop(context),
                        child: Text(_t('取消', 'Cancel'))),
                    FilledButton(
                        key: const ValueKey('android-save-annual'),
                        onPressed: _saving ? null : _save,
                        child: Text(_saving
                            ? _t('保存中…', 'Saving…')
                            : _t('保存年度任务', 'Save annual task'))),
                  ]),
                ])),
          ]),
        ),
      ));
}

class _SubtaskEditor extends StatefulWidget {
  const _SubtaskEditor({required this.isChinese, this.initial});
  final bool isChinese;
  final AnnualPlanSubtask? initial;
  @override
  State<_SubtaskEditor> createState() => _SubtaskEditorState();
}

class _SubtaskEditorState extends State<_SubtaskEditor> {
  late final TextEditingController _title, _detail;
  String? _error;
  String _t(String zh, String en) => widget.isChinese ? zh : en;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initial?.title ?? '');
    _detail = TextEditingController(text: widget.initial?.detail ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: Text(_t('子任务', 'Subtask')),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              key: const ValueKey('android-subtask-title'),
              controller: _title,
              decoration: InputDecoration(
                  labelText: _t('名称', 'Title'), errorText: _error)),
          TextField(
              key: const ValueKey('android-subtask-detail'),
              controller: _detail,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: _t('描述', 'Description'))),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('取消', 'Cancel'))),
          FilledButton(
              key: const ValueKey('android-save-subtask'),
              onPressed: () {
                if (_title.text.trim().isEmpty) {
                  setState(
                      () => _error = _t('请输入子任务名称', 'Enter a subtask title'));
                  return;
                }
                Navigator.pop(
                    context,
                    AnnualPlanSubtask(
                        id: widget.initial?.id ?? '',
                        title: _title.text.trim(),
                        detail: _detail.text.trim(),
                        completed: widget.initial?.completed ?? false,
                        sortOrder: widget.initial?.sortOrder ?? 0));
              },
              child: Text(_t('保存子任务', 'Save subtask'))),
        ],
      );
}
