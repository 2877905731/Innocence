import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/stats/domain/models/stats_overview.dart';

String _text(BuildContext context, String zh, String en) {
  return localizedText(context, zh, en);
}

class StatsPage extends StatefulWidget {
  const StatsPage({
    super.key,
    required this.profile,
    required this.initialOverview,
    required this.onLoadStatsOverview,
    required this.onDeleteFailureRecord,
    required this.onRemindTeammate,
  });

  final UserProfile profile;
  final StatsOverview initialOverview;
  final Future<StatsOverview?> Function({int days}) onLoadStatsOverview;
  final Future<bool> Function(String date) onDeleteFailureRecord;
  final Future<bool> Function(int teammateUserId) onRemindTeammate;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late StatsOverview _overview;
  bool _isLoading = false;
  _TrendMetric _metric = _TrendMetric.study;
  _FailureFilter _failureFilter = _FailureFilter.all;
  _FailureSort _failureSort = _FailureSort.latest;

  List<StatsFailureRecord> get _visibleFailures {
    final items = _overview.failures
        .where((failure) => _matchesFailureFilter(failure, _failureFilter))
        .toList();
    items.sort(
        (left, right) => _compareFailureRecords(left, right, _failureSort));
    return items;
  }

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadRange(int days) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    StatsOverview? nextOverview;
    try {
      nextOverview = await widget.onLoadStatsOverview(days: days);
    } catch (_) {
      nextOverview = null;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      if (nextOverview != null) {
        _overview = nextOverview;
      }
      _isLoading = false;
    });

    if (nextOverview == null) {
      _showMessage(
        _text(
          context,
          '统计中心刷新失败，当前显示最近一次缓存数据。',
          'Failed to refresh statistics. Showing the latest cached view.',
        ),
      );
    }
  }

  Future<void> _deleteFailureRecord(StatsFailureRecord failure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, '删除失败记录', 'Delete failure record')),
          content: Text(
            _text(
              context,
              '确定删除 ${failure.date} 的失败记录吗？这只会清除失败备注，不会删除当天其他学习数据。',
              'Remove the failure record for ${failure.date}? This only clears the failure note and keeps your other study data intact.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(context, '取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text(context, '删除', 'Delete')),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var deleted = false;
    StatsOverview? nextOverview;
    try {
      deleted = await widget.onDeleteFailureRecord(failure.date);
      nextOverview =
          await widget.onLoadStatsOverview(days: _overview.rangeDays);
    } catch (_) {
      nextOverview = null;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      if (nextOverview != null) {
        _overview = nextOverview;
      }
      _isLoading = false;
    });

    _showMessage(
      deleted
          ? _text(context, '失败记录已删除。', 'Failure record deleted.')
          : _text(context, '没有删除任何失败记录。', 'No failure record was deleted.'),
    );
    if (deleted && nextOverview == null) {
      _showMessage(
        _text(
          context,
          '记录已处理，但统计未能立即刷新，请稍后手动刷新。',
          'The record changed, but statistics could not refresh immediately. Please refresh later.',
        ),
      );
    }
  }

  Future<void> _remindTeammate(TeammateStats teammate) async {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var sent = false;
    StatsOverview? nextOverview;
    try {
      sent = await widget.onRemindTeammate(teammate.userId);
      nextOverview =
          await widget.onLoadStatsOverview(days: _overview.rangeDays);
    } catch (_) {
      nextOverview = null;
    }
    if (!mounted) {
      return;
    }

    setState(() {
      if (nextOverview != null) {
        _overview = nextOverview;
      }
      _isLoading = false;
    });

    _showMessage(
      sent
          ? _text(
              context,
              '队友提醒已发送。',
              'Teammate reminder sent.',
            )
          : _text(
              context,
              '队友提醒发送失败。',
              'Unable to send the teammate reminder.',
            ),
    );
    if (sent && nextOverview == null) {
      _showMessage(
        _text(
          context,
          '提醒已发送，但统计未能立即刷新。',
          'Reminder sent, but statistics did not refresh immediately.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text(context, '返回', 'Back'),
      title: _text(context, '统计中心', 'Statistics center'),
      description: _text(
        context,
        '这里集中展示学习时长、签到结果、完成率、趋势图和失败记录。',
        'Study time, check-in success, completion rate, and low-pressure failure notes all live here.',
      ),
      headerActions: [
        OutlinedButton.icon(
          onPressed: _isLoading
              ? null
              : () async {
                  await _loadRange(_overview.rangeDays);
                },
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(
            _isLoading
                ? _text(context, '刷新中', 'Refreshing')
                : _text(context, '刷新', 'Refresh'),
          ),
        ),
      ],
      children: [
        GlassPanel(
          lightStyle: true,
          child: _StatsHeroCard(
            profile: widget.profile,
            overview: _overview,
            isLoading: _isLoading,
            onRangeSelected: _loadRange,
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _TrendDetailCard(
            overview: _overview,
            metric: _metric,
            onMetricChanged: (metric) {
              setState(() {
                _metric = metric;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _DailyBreakdownCard(
            overview: _overview,
            metric: _metric,
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _TeammateInsightCard(
            teammates: _overview.teammates,
            isLoading: _isLoading,
            onRemind: _remindTeammate,
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _FailureDigestCard(
            failures: _visibleFailures,
            totalFailureCount: _overview.failures.length,
            selectedFilter: _failureFilter,
            selectedSort: _failureSort,
            isLoading: _isLoading,
            onFilterChanged: (filter) {
              setState(() {
                _failureFilter = filter;
              });
            },
            onSortChanged: (sort) {
              setState(() {
                _failureSort = sort;
              });
            },
            onDelete: _deleteFailureRecord,
          ),
        ),
      ],
    );
  }
}

class _StatsHeroCard extends StatelessWidget {
  const _StatsHeroCard({
    required this.profile,
    required this.overview,
    required this.isLoading,
    required this.onRangeSelected,
  });

  final UserProfile profile;
  final StatsOverview overview;
  final bool isLoading;
  final Future<void> Function(int days) onRangeSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileDisplayName = _profileDisplayName(context, profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(context, '$profileDisplayName 的统计概览',
                      'Overview for $profileDisplayName'),
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _text(
                    context,
                    '首页保持轻量展示，这里则提供当前时间范围内更完整的学习视图。',
                    'This page keeps the home page light, while giving the selected range a fuller view.',
                  ),
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(_text(context, '近 7 天', '7 days')),
                  selected: overview.rangeDays == 7,
                  onSelected: isLoading
                      ? null
                      : (_) async {
                          await onRangeSelected(7);
                        },
                ),
                ChoiceChip(
                  label: Text(_text(context, '近 30 天', '30 days')),
                  selected: overview.rangeDays == 30,
                  onSelected: isLoading
                      ? null
                      : (_) async {
                          await onRangeSelected(30);
                        },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _SummaryTile(
              title: _text(context, '范围学习时长', 'Range study time'),
              value:
                  _formatMinutes(context, overview.totalStudyDurationMinutes),
              hint: _text(context, '当前选择范围内已完成的专注学习总时长',
                  'Finished focus sessions in the selected range'),
            ),
            _SummaryTile(
              title: _text(context, '完成番茄次数', 'Pomodoros done'),
              value: '${overview.totalPomodoroCompleted}',
              hint: _text(context, '已完成的番茄学习循环次数', 'Completed study loops'),
            ),
            _SummaryTile(
              title: _text(context, '签到成功天数', 'Check-in days'),
              value: '${overview.totalCheckInDays}',
              hint: _text(context, '当前范围内签到成功的天数',
                  'Successes inside the selected range'),
            ),
            _SummaryTile(
              title: _text(context, '有计划天数', 'Active plan days'),
              value: '${overview.activePlanDays}',
              hint: _text(
                  context, '当天存在计划条目的日期数量', 'Days that had actual plan items'),
            ),
            _SummaryTile(
              title: _text(context, '累计学习时长', 'All-time study'),
              value: _formatMinutes(context, profile.studyDurationTotal),
              hint: _text(context, '账号历史累计完成的学习时长',
                  'Profile total across finished sessions'),
            ),
            _SummaryTile(
              title: _text(context, '累计签到天数', 'All-time check-ins'),
              value: _text(context, '${profile.checkInDaysTotal} 天',
                  '${profile.checkInDaysTotal} d'),
              hint: _text(context, '账号历史累计签到成功天数',
                  'Lifetime accumulated successful days'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendDetailCard extends StatelessWidget {
  const _TrendDetailCard({
    required this.overview,
    required this.metric,
    required this.onMetricChanged,
  });

  final StatsOverview overview;
  final _TrendMetric metric;
  final ValueChanged<_TrendMetric> onMetricChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final lensSummary = _buildTrendLensSummary(context, overview.trend, metric);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text(context, '趋势详情', 'Trend detail'),
            style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          _text(
            context,
            '使用同一张趋势图，通过切换维度查看学习、签到、完成率和失败记录。',
            'Use one chart source and switch the lens: study, check-in, completion, or failure.',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _MetricSelectorChip(
              label: _text(context, '学习', 'Study'),
              selected: metric == _TrendMetric.study,
              onSelected: () => onMetricChanged(_TrendMetric.study),
            ),
            _MetricSelectorChip(
              label: _text(context, '签到', 'Check-in'),
              selected: metric == _TrendMetric.checkIn,
              onSelected: () => onMetricChanged(_TrendMetric.checkIn),
            ),
            _MetricSelectorChip(
              label: _text(context, '完成率', 'Completion'),
              selected: metric == _TrendMetric.completion,
              onSelected: () => onMetricChanged(_TrendMetric.completion),
            ),
            _MetricSelectorChip(
              label: _text(context, '失败', 'Failure'),
              selected: metric == _TrendMetric.failure,
              onSelected: () => onMetricChanged(_TrendMetric.failure),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _trendMetricColor(metric).withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: _trendMetricColor(metric).withValues(alpha: 0.16),
            ),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                label: _text(context, '当前维度', 'Current lens'),
                value: _trendMetricTitle(context, metric),
              ),
              _InfoChip(
                label:
                    '${_text(context, '峰值日', 'Peak day')} (${lensSummary.peakDayLabel})',
                value: lensSummary.peakValueLabel,
              ),
              _InfoChip(
                label: _text(context, '日均值', 'Daily average'),
                value: lensSummary.averageValueLabel,
              ),
              _InfoChip(
                label:
                    '${_text(context, '最新一天', 'Latest day')} (${lensSummary.latestDayLabel})',
                value: lensSummary.latestValueLabel,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _TrendGraph(
          points: overview.trend,
          metric: metric,
          height: 260,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoChip(
              label: _text(context, '计划完成率', 'Plan completion rate'),
              value: '${overview.planCompletionRate}%',
            ),
            _InfoChip(
              label: _text(context, '签到成功率', 'Check-in success rate'),
              value: '${overview.checkInSuccessRate}%',
            ),
            _InfoChip(
              label: _text(context, '失败次数', 'Failed attempts'),
              value: '${overview.totalFailedCheckInAttempts}',
            ),
            _InfoChip(
              label: _text(context, '已加载天数', 'Trend days loaded'),
              value: '${overview.trend.length}',
            ),
          ],
        ),
      ],
    );
  }
}

class _DailyBreakdownCard extends StatelessWidget {
  const _DailyBreakdownCard({
    required this.overview,
    required this.metric,
  });

  final StatsOverview overview;
  final _TrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text(context, '每日拆解', 'Daily breakdown'),
            style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          _text(
            context,
            '每一行都会保留当天足够的上下文信息，不用再跳转别的页面也能看懂当天情况。',
            'Each row keeps enough context to understand what happened on that day without opening another page.',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        if (overview.trend.isEmpty)
          _EmptyStateCard(
            title: _text(context, '暂时还没有每日数据', 'No daily data yet'),
            description: _text(
              context,
              '开始使用计划、专注和签到后，这里会自动逐步填充真实数据。',
              'Once you start completing plans, focus sessions, and check-ins, this area will fill in automatically.',
            ),
          )
        else
          Column(
            children: overview.trend.reversed.map((point) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DayBreakdownTile(
                  point: point,
                  metric: metric,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _FailureDigestCard extends StatelessWidget {
  const _FailureDigestCard({
    required this.failures,
    required this.totalFailureCount,
    required this.selectedFilter,
    required this.selectedSort,
    required this.isLoading,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onDelete,
  });

  final List<StatsFailureRecord> failures;
  final int totalFailureCount;
  final _FailureFilter selectedFilter;
  final _FailureSort selectedSort;
  final bool isLoading;
  final ValueChanged<_FailureFilter> onFilterChanged;
  final ValueChanged<_FailureSort> onSortChanged;
  final Future<void> Function(StatsFailureRecord failure) onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleAttemptCount = failures.fold<int>(
      0,
      (current, failure) => current + failure.attemptCount,
    );
    final visibleStudyMinutes = failures.fold<int>(
      0,
      (current, failure) => current + failure.studyDurationMinutes,
    );
    final averageProgress = failures.isEmpty
        ? 0
        : (failures.fold<int>(
                  0,
                  (current, failure) =>
                      current + _failureProgressPercent(failure),
                ) /
                failures.length)
            .round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text(context, '失败记录', 'Failure digest'),
            style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          _text(
            context,
            '这里是低压力的失败记录区，用来帮助回看遗漏，而不是把它当作惩罚。',
            'This is a low-pressure record area. It highlights misses so users can review them without treating them like punishments.',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        if (totalFailureCount > 0) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                label: _text(context, '当前显示天数', 'Visible days'),
                value: '${failures.length}/$totalFailureCount',
              ),
              _InfoChip(
                label: _text(context, '失败次数', 'Failed attempts'),
                value: '$visibleAttemptCount',
              ),
              _InfoChip(
                label: _text(context, '平均完成率', 'Avg completion'),
                value: '$averageProgress%',
              ),
              _InfoChip(
                label: _text(context, '保留学习时长', 'Study kept'),
                value: _formatMinutes(context, visibleStudyMinutes),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_text(context, '筛选视图', 'Filter view'),
              style: textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _FailureFilter.values.map((filter) {
              return ChoiceChip(
                label: Text(_failureFilterLabel(context, filter)),
                selected: filter == selectedFilter,
                onSelected: isLoading
                    ? null
                    : (_) {
                        onFilterChanged(filter);
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(_text(context, '排序方式', 'Sort order'),
              style: textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _FailureSort.values.map((sort) {
              return ChoiceChip(
                label: Text(_failureSortLabel(context, sort)),
                selected: sort == selectedSort,
                onSelected: isLoading
                    ? null
                    : (_) {
                        onSortChanged(sort);
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            failures.length == totalFailureCount
                ? _text(context, '当前已显示该范围内全部失败记录日期。',
                    'Showing all recorded failure days in this range.')
                : _text(
                    context,
                    '当前显示 $totalFailureCount 天失败记录中的 ${failures.length} 天。',
                    'Showing ${failures.length} of $totalFailureCount failure days in this range.',
                  ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
        ],
        if (totalFailureCount == 0)
          _EmptyStateCard(
            title: _text(context, '当前范围内没有签到失败记录',
                'No failed check-in attempts in this range'),
            description: _text(
              context,
              '这通常表示当前范围内签到都成功了，或者还没有记录签到尝试。',
              'That usually means the selected range has either successful check-ins or no check-in attempts recorded yet.',
            ),
          )
        else if (failures.isEmpty)
          _EmptyStateCard(
            title: _text(context, '当前筛选下没有匹配记录', 'No records match this view'),
            description: _text(
              context,
              '可以切换其他筛选条件，查看重复尝试、有学习时长支撑的失败记录或完成度最低的日期。',
              'Try another filter to surface repeated tries, study-backed misses, or the lowest-progress days.',
            ),
          )
        else
          Column(
            children: failures.map((failure) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FailureRecordTile(
                  failure: failure,
                  isLoading: isLoading,
                  onDelete: () => onDelete(failure),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _TeammateInsightCard extends StatelessWidget {
  const _TeammateInsightCard({
    required this.teammates,
    required this.isLoading,
    required this.onRemind,
  });

  final List<TeammateStats> teammates;
  final bool isLoading;
  final Future<void> Function(TeammateStats teammate) onRemind;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeCount =
        teammates.where((teammate) => teammate.activeStudy).length;
    final totalTodayMinutes = teammates.fold<int>(
      0,
      (current, teammate) => current + teammate.todayStudyDurationMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text(context, '队友视图', 'Teammate insight'),
            style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          _text(
            context,
            '这里展示简化团队视图：查看队友进度、当前学习状态，并在需要时发出提醒。',
            'This is the simple team view: see teammate progress, current study state, and send a gentle reminder when needed.',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        if (teammates.isEmpty)
          _EmptyStateCard(
            title: _text(context, '暂时还没有队友数据', 'No teammate data yet'),
            description: _text(
              context,
              '当前账号还没有加入有效团队，所以统计中心暂时只显示个人视图。',
              'This account is not in an active team yet, so the statistics center is still showing the personal view only.',
            ),
          )
        else ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                  label: _text(context, '团队人数', 'Team size'),
                  value: '${teammates.length + 1}'),
              _InfoChip(
                  label: _text(context, '当前专注中', 'Active now'),
                  value: '$activeCount'),
              _InfoChip(
                label: _text(context, '团队今日学习', 'Today team study'),
                value: _formatMinutes(context, totalTodayMinutes),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            children: teammates.map((teammate) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TeammateStatTile(
                  teammate: teammate,
                  isLoading: isLoading,
                  onRemind: () => onRemind(teammate),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.hint,
  });

  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: SurfacePalette.ink,
                ),
          ),
          const SizedBox(height: 8),
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SurfacePalette.ink,
                ),
          ),
        ],
      ),
    );
  }
}

class _DayBreakdownTile extends StatelessWidget {
  const _DayBreakdownTile({
    required this.point,
    required this.metric,
  });

  final StatsTrendPoint point;
  final _TrendMetric metric;

  @override
  Widget build(BuildContext context) {
    final accent = _trendMetricColor(metric);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${point.label}  |  ${point.date}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                _headlineMetric(context, point, metric),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: SurfacePalette.ink,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                  label: _text(context, '学习', 'Study'),
                  value: _formatMinutes(context, point.studyDurationMinutes)),
              _MiniPill(
                  label: _text(context, '番茄', 'Pomodoro'),
                  value: '${point.pomodoroCompletedCount}'),
              _MiniPill(
                label: _text(context, '计划', 'Plan'),
                value: '${point.planCompletedCount}/${point.planTotalCount}',
              ),
              _MiniPill(
                  label: _text(context, '完成率', 'Completion'),
                  value: '${point.planCompletionRate}%'),
              _MiniPill(
                  label: _text(context, '签到', 'Check-in'),
                  value: '${point.checkInSuccessRate}%'),
              _MiniPill(
                  label: _text(context, '失败', 'Failures'),
                  value: '${point.failedCheckInAttempts}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _daySummary(context, point),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _FailureRecordTile extends StatelessWidget {
  const _FailureRecordTile({
    required this.failure,
    required this.isLoading,
    required this.onDelete,
  });

  final StatsFailureRecord failure;
  final bool isLoading;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0x26FFAA82),
            SurfacePalette.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x38FFB08E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${failure.label}  |  ${failure.date}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        await onDelete();
                      },
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(_text(context, '删除', 'Delete')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                  label: _text(context, '失败次数', 'Failed attempts'),
                  value: '${failure.attemptCount}'),
              _MiniPill(
                  label: _text(context, '学习', 'Study'),
                  value: _formatMinutes(context, failure.studyDurationMinutes)),
              _MiniPill(
                label: _text(context, '计划进度', 'Plan progress'),
                value:
                    '${failure.planCompletedCount}/${failure.planTotalCount}',
              ),
              if (failure.lastAttemptTime.isNotEmpty)
                _MiniPill(
                    label: _text(context, '最后尝试', 'Last try'),
                    value: failure.lastAttemptTime),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            failure.latestReason.trim().isEmpty
                ? _text(
                    context,
                    '当天记录了失败尝试，但当前记录没有留下文字原因。',
                    'A failed attempt was recorded for this day, but the current record did not include a text reason.',
                  )
                : failure.latestReason,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TeammateStatTile extends StatelessWidget {
  const _TeammateStatTile({
    required this.teammate,
    required this.isLoading,
    required this.onRemind,
  });

  final TeammateStats teammate;
  final bool isLoading;
  final Future<void> Function() onRemind;

  @override
  Widget build(BuildContext context) {
    final stageColor = teammate.activeStudy ? AppColors.mint : AppColors.glow;
    final displayName = _teammateDisplayName(context, teammate);
    final initial =
        displayName.isEmpty ? '?' : displayName.characters.first.toUpperCase();
    final title =
        teammate.userNo.trim().isEmpty || displayName == teammate.userNo
            ? displayName
            : '$displayName  |  ${teammate.userNo}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              stageColor.withValues(alpha: teammate.activeStudy ? 0.28 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      stageColor.withValues(alpha: 0.75),
                      Colors.white.withValues(alpha: 0.14),
                    ],
                  ),
                ),
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      teammate.activeStudy
                          ? _text(
                              context,
                              '${_teammateStageLabel(context, teammate.activeStageName, teammate.activeStudy)}中${teammate.activeTaskName.trim().isEmpty ? '' : ' - ${teammate.activeTaskName}'}',
                              '${_teammateStageLabel(context, teammate.activeStageName, teammate.activeStudy)} now${teammate.activeTaskName.trim().isEmpty ? '' : ' - ${teammate.activeTaskName}'}',
                            )
                          : _text(context, '当前没有进行中的学习专注。',
                              'Not currently in an active study session'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: isLoading || !teammate.remindable
                    ? null
                    : () async {
                        await onRemind();
                      },
                icon: const Icon(Icons.notifications_active_rounded),
                label: Text(
                  teammate.remindable
                      ? _text(context, '提醒', 'Remind')
                      : _text(
                          context,
                          '今日已提醒 ${teammate.reminderCountToday}/5',
                          'Reminded ${teammate.reminderCountToday}/5',
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniPill(
                label: _text(context, '今日计划', 'Today plan'),
                value: teammate.todayPlanProgressLabel,
              ),
              _MiniPill(
                label: _text(context, '今日学习', 'Today study'),
                value:
                    _formatMinutes(context, teammate.todayStudyDurationMinutes),
              ),
              _MiniPill(
                label: _text(context, '累计签到', 'Total check-ins'),
                value: '${teammate.totalCheckInDays}',
              ),
              _MiniPill(
                label: _text(context, '今日提醒', 'Reminders today'),
                value: '${teammate.reminderCountToday}/5',
              ),
              if (teammate.allowStudyView)
                _MiniPill(
                  label: _text(context, '累计学习', 'All-time study'),
                  value: _formatMinutes(
                      context, teammate.totalStudyDurationMinutes),
                ),
            ],
          ),
          if (!teammate.allowStudyView) ...[
            const SizedBox(height: 12),
            Text(
              _text(
                context,
                '该队友隐藏了完整累计学习时长，因此这里只显示团队可见的安全进度信息。',
                'This teammate has hidden the full study total, so only team-safe progress hints are shown here.',
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SurfacePalette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}

enum _TrendMetric {
  study,
  checkIn,
  completion,
  failure,
}

enum _FailureFilter {
  all,
  repeated,
  studied,
  zeroProgress,
}

enum _FailureSort {
  latest,
  attempts,
  study,
  progress,
}

class _MetricSelectorChip extends StatelessWidget {
  const _MetricSelectorChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _TrendGraph extends StatelessWidget {
  const _TrendGraph({
    required this.points,
    required this.metric,
    this.height = 220,
  });

  final List<StatsTrendPoint> points;
  final _TrendMetric metric;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bars = points.isEmpty
        ? <_TrendBarData>[]
        : points
            .map(
              (point) => _TrendBarData(
                label: point.label,
                value: _trendValueOf(point, metric),
                tooltip: _trendTooltipOf(context, point, metric),
              ),
            )
            .toList();

    final maxValue = bars.fold<int>(
      0,
      (current, bar) => bar.value > current ? bar.value : current,
    );
    final safeMaxValue = maxValue <= 0 ? 1 : maxValue;
    final barWidth = bars.length <= 7 ? 58.0 : 44.0;
    final usableBarHeight = height > 88 ? height - 88 : height * 0.6;

    if (bars.isEmpty) {
      return _EmptyStateCard(
        title: _text(context, '暂时还没有趋势数据', 'No trend data yet'),
        description: _text(
          context,
          '开始使用计划、专注和签到后，这张图会逐步填入真实进展。',
          'Start using plans, focus sessions, and check-in to fill this chart with real progress.',
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SurfacePalette.softSurface,
            SurfacePalette.surface,
          ],
        ),
        border: Border.all(color: SurfacePalette.borderSoft),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _trendMetricColor(metric),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _trendMetricColor(metric).withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _text(context, '${_trendMetricTitle(context, metric)}视图',
                      '${_trendMetricTitle(context, metric)} view'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                _trendMetricHint(context, metric),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SurfacePalette.subtle,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trendAxisLabelLocalized(context, safeMaxValue, metric),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SurfacePalette.subtle,
                            ),
                      ),
                      Text(
                        _trendAxisLabelLocalized(
                          context,
                          (safeMaxValue / 2).ceil(),
                          metric,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SurfacePalette.subtle,
                            ),
                      ),
                      Text(
                        _trendAxisLabelLocalized(context, 0, metric),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SurfacePalette.subtle,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(4, (_) {
                            return Container(
                              height: 1,
                              color: SurfacePalette.borderSoft,
                            );
                          }),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: bars.length * barWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(bars.length, (index) {
                              final bar = bars[index];
                              final ratio = bar.value / safeMaxValue;
                              final color = _trendMetricColor(metric);
                              final isLatest = index == bars.length - 1;
                              return SizedBox(
                                width: barWidth,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        bar.tooltip,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isLatest
                                                  ? SurfacePalette.ink
                                                  : SurfacePalette.subtle,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                            6,
                                            8,
                                            6,
                                            6,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white.withValues(
                                                  alpha: isLatest ? 0.12 : 0.08,
                                                ),
                                                Colors.white
                                                    .withValues(alpha: 0.04),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: isLatest
                                                  ? color.withValues(
                                                      alpha: 0.32)
                                                  : Colors.white.withValues(
                                                      alpha: 0.10,
                                                    ),
                                            ),
                                          ),
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              width: double.infinity,
                                              height: 24 +
                                                  (usableBarHeight * ratio),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    color.withValues(
                                                        alpha: 0.94),
                                                    color.withValues(
                                                        alpha: 0.40),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color:
                                                      Colors.white.withValues(
                                                    alpha: 0.12,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: color.withValues(
                                                      alpha: isLatest
                                                          ? 0.34
                                                          : 0.22,
                                                    ),
                                                    blurRadius:
                                                        isLatest ? 18 : 12,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        bar.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: isLatest
                                                  ? SurfacePalette.ink
                                                  : SurfacePalette.subtle,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBarData {
  const _TrendBarData({
    required this.label,
    required this.value,
    required this.tooltip,
  });

  final String label;
  final int value;
  final String tooltip;
}

class _TrendLensSummary {
  const _TrendLensSummary({
    required this.peakDayLabel,
    required this.peakValueLabel,
    required this.averageValueLabel,
    required this.latestDayLabel,
    required this.latestValueLabel,
  });

  final String peakDayLabel;
  final String peakValueLabel;
  final String averageValueLabel;
  final String latestDayLabel;
  final String latestValueLabel;
}

int _trendValueOf(StatsTrendPoint point, _TrendMetric metric) {
  return switch (metric) {
    _TrendMetric.study => point.studyDurationMinutes,
    _TrendMetric.checkIn => point.checkInSuccessCount,
    _TrendMetric.completion => point.planCompletionRate,
    _TrendMetric.failure => point.failedCheckInAttempts,
  };
}

String _trendTooltipOf(
  BuildContext context,
  StatsTrendPoint point,
  _TrendMetric metric,
) {
  return switch (metric) {
    _TrendMetric.study =>
      _formatCompactMinutes(context, point.studyDurationMinutes),
    _TrendMetric.checkIn => '${point.checkInSuccessCount}',
    _TrendMetric.completion => '${point.planCompletionRate}%',
    _TrendMetric.failure => '${point.failedCheckInAttempts}',
  };
}

Color _trendMetricColor(_TrendMetric metric) {
  return switch (metric) {
    _TrendMetric.study => AppColors.glow,
    _TrendMetric.checkIn => AppColors.mint,
    _TrendMetric.completion => const Color(0xFFFFD66B),
    _TrendMetric.failure => const Color(0xFFFFA17A),
  };
}

String _trendMetricTitle(BuildContext context, _TrendMetric metric) {
  return switch (metric) {
    _TrendMetric.study => _text(context, '学习时长', 'Study time'),
    _TrendMetric.checkIn => _text(context, '签到情况', 'Check-in success'),
    _TrendMetric.completion => _text(context, '计划完成率', 'Plan completion'),
    _TrendMetric.failure => _text(context, '失败次数', 'Failure attempts'),
  };
}

String _trendMetricHint(BuildContext context, _TrendMetric metric) {
  return switch (metric) {
    _TrendMetric.study =>
      _text(context, '按天统计的学习分钟数', 'Minutes across each day'),
    _TrendMetric.checkIn =>
      _text(context, '按天统计的签到成功次数', 'Successful check-in days'),
    _TrendMetric.completion =>
      _text(context, '按天统计的完成率', 'Completion ratio by day'),
    _TrendMetric.failure =>
      _text(context, '按天统计的失败尝试次数', 'Failed attempts by day'),
  };
}

String _trendAxisLabelLocalized(
  BuildContext context,
  int value,
  _TrendMetric metric,
) {
  return switch (metric) {
    _TrendMetric.study => _formatCompactMinutes(context, value),
    _TrendMetric.checkIn => '$value',
    _TrendMetric.completion => '$value%',
    _TrendMetric.failure => '$value',
  };
}

String _headlineMetric(
  BuildContext context,
  StatsTrendPoint point,
  _TrendMetric metric,
) {
  return switch (metric) {
    _TrendMetric.study =>
      _formatCompactMinutes(context, point.studyDurationMinutes),
    _TrendMetric.checkIn => '${point.checkInSuccessCount}',
    _TrendMetric.completion => '${point.planCompletionRate}%',
    _TrendMetric.failure => '${point.failedCheckInAttempts}',
  };
}

String _teammateStageLabel(
  BuildContext context,
  String stageName,
  bool activeStudy,
) {
  switch (stageName.trim().toLowerCase()) {
    case 'study':
      return _text(context, '学习', 'Study');
    case 'break':
      return _text(context, '休息', 'Break');
    case 'finished':
      return _text(context, '已完成', 'Finished');
    default:
      return activeStudy
          ? _text(context, '学习', 'Study')
          : _text(context, '空闲', 'Idle');
  }
}

_TrendLensSummary _buildTrendLensSummary(
  BuildContext context,
  List<StatsTrendPoint> points,
  _TrendMetric metric,
) {
  if (points.isEmpty) {
    return const _TrendLensSummary(
      peakDayLabel: '--',
      peakValueLabel: '--',
      averageValueLabel: '--',
      latestDayLabel: '--',
      latestValueLabel: '--',
    );
  }

  final peakPoint = points.reduce((best, current) {
    return _trendValueOf(current, metric) >= _trendValueOf(best, metric)
        ? current
        : best;
  });
  final total = points.fold<double>(
    0,
    (current, point) => current + _trendValueOf(point, metric),
  );
  final latestPoint = points.last;

  return _TrendLensSummary(
    peakDayLabel: peakPoint.label,
    peakValueLabel:
        _trendValueLabel(context, metric, _trendValueOf(peakPoint, metric)),
    averageValueLabel: _trendValueLabel(context, metric, total / points.length),
    latestDayLabel: latestPoint.label,
    latestValueLabel:
        _trendValueLabel(context, metric, _trendValueOf(latestPoint, metric)),
  );
}

bool _matchesFailureFilter(
  StatsFailureRecord failure,
  _FailureFilter filter,
) {
  return switch (filter) {
    _FailureFilter.all => true,
    _FailureFilter.repeated => failure.attemptCount >= 2,
    _FailureFilter.studied => failure.studyDurationMinutes > 0,
    _FailureFilter.zeroProgress => failure.planCompletedCount == 0,
  };
}

String _failureFilterLabel(BuildContext context, _FailureFilter filter) {
  return switch (filter) {
    _FailureFilter.all => _text(context, '全部', 'All'),
    _FailureFilter.repeated => _text(context, '重复尝试', 'Repeated tries'),
    _FailureFilter.studied => _text(context, '失败但仍有学习', 'Studied anyway'),
    _FailureFilter.zeroProgress => _text(context, '零进度', 'Zero progress'),
  };
}

String _failureSortLabel(BuildContext context, _FailureSort sort) {
  return switch (sort) {
    _FailureSort.latest => _text(context, '最新优先', 'Latest first'),
    _FailureSort.attempts => _text(context, '尝试次数最多', 'Most tries'),
    _FailureSort.study => _text(context, '学习时长最多', 'Most study'),
    _FailureSort.progress => _text(context, '完成度最低', 'Least progress'),
  };
}

int _compareFailureRecords(
  StatsFailureRecord left,
  StatsFailureRecord right,
  _FailureSort sort,
) {
  switch (sort) {
    case _FailureSort.latest:
      final byDate = _parseFailureDate(right.date).compareTo(
        _parseFailureDate(left.date),
      );
      if (byDate != 0) {
        return byDate;
      }
      return right.attemptCount.compareTo(left.attemptCount);
    case _FailureSort.attempts:
      final byAttempts = right.attemptCount.compareTo(left.attemptCount);
      if (byAttempts != 0) {
        return byAttempts;
      }
      return _parseFailureDate(right.date).compareTo(
        _parseFailureDate(left.date),
      );
    case _FailureSort.study:
      final byStudy = right.studyDurationMinutes.compareTo(
        left.studyDurationMinutes,
      );
      if (byStudy != 0) {
        return byStudy;
      }
      return _parseFailureDate(right.date).compareTo(
        _parseFailureDate(left.date),
      );
    case _FailureSort.progress:
      final byProgress = _failureProgressRatio(left).compareTo(
        _failureProgressRatio(right),
      );
      if (byProgress != 0) {
        return byProgress;
      }
      return _parseFailureDate(right.date).compareTo(
        _parseFailureDate(left.date),
      );
  }
}

double _failureProgressRatio(StatsFailureRecord failure) {
  if (failure.planTotalCount <= 0) {
    return failure.planCompletedCount > 0 ? 1 : 0;
  }
  return failure.planCompletedCount / failure.planTotalCount;
}

int _failureProgressPercent(StatsFailureRecord failure) {
  return (_failureProgressRatio(failure) * 100).round();
}

DateTime _parseFailureDate(String value) {
  return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String _trendValueLabel(BuildContext context, _TrendMetric metric, num value) {
  return switch (metric) {
    _TrendMetric.study => _formatMinutes(context, value.round()),
    _TrendMetric.checkIn => _formatUnitCount(
        context,
        value,
        singularZh: '次签到',
        pluralZh: '次签到',
        singularEn: 'check-in',
        pluralEn: 'check-ins',
      ),
    _TrendMetric.completion => '${value.round()}%',
    _TrendMetric.failure => _formatUnitCount(
        context,
        value,
        singularZh: '次失败',
        pluralZh: '次失败',
        singularEn: 'fail',
        pluralEn: 'fails',
      ),
  };
}

String _daySummary(BuildContext context, StatsTrendPoint point) {
  if (!point.hasPlan) {
    return _text(
      context,
      '这一天没有检测到有效计划，因此图表主要反映的是自由学习或休息日状态。',
      'No active plan was detected on this day, so the chart mostly reflects optional study activity or a rest day.',
    );
  }
  if (point.checkInSuccessCount > 0) {
    return _text(
      context,
      '这一天已顺利完成，学习时长、计划完成率和签到结果都比较健康。',
      'The planned day closed successfully. Study, completion, and check-in all landed in a healthy range.',
    );
  }
  if (point.failedCheckInAttempts > 0) {
    return _text(
      context,
      '这一天的计划中出现了签到失败，当前行保留了当日完成度和学习时长，方便复盘。',
      'A check-in attempt failed on this plan day. The row keeps the nearby completion and study context for review.',
    );
  }
  return _text(
    context,
    '这一天有计划安排，但暂时还没有成功签到记录。',
    'This was a plan day without a successful check-in record yet.',
  );
}

String _profileDisplayName(BuildContext context, UserProfile profile) {
  final nickname = profile.nickname.trim();
  if (nickname.isNotEmpty) {
    return nickname;
  }
  final userNo = profile.userNo.trim();
  if (userNo.isNotEmpty) {
    return userNo;
  }
  return _text(context, '我的', 'My');
}

String _teammateDisplayName(BuildContext context, TeammateStats teammate) {
  final nickname = teammate.nickname.trim();
  if (nickname.isNotEmpty) {
    return nickname;
  }
  final userNo = teammate.userNo.trim();
  if (userNo.isNotEmpty) {
    return userNo;
  }
  return _text(context, '队友', 'Teammate');
}

String _formatCompactMinutes(BuildContext context, int minutes) {
  final normalized = minutes < 0 ? 0 : minutes;
  final hours = normalized ~/ 60;
  final remainingMinutes = normalized % 60;
  if (isChineseLocale(context)) {
    if (hours == 0) {
      return '$remainingMinutes分';
    }
    if (remainingMinutes == 0) {
      return '$hours时';
    }
    return '$hours时$remainingMinutes分';
  }
  if (hours == 0) {
    return '${remainingMinutes}m';
  }
  if (remainingMinutes == 0) {
    return '${hours}h';
  }
  return '${hours}h${remainingMinutes}m';
}

String _formatUnitCount(
  BuildContext context,
  num value, {
  required String singularZh,
  required String pluralZh,
  required String singularEn,
  required String pluralEn,
}) {
  final normalized = value.toDouble();
  final isWhole = normalized == normalized.roundToDouble();
  final display =
      isWhole ? '${normalized.toInt()}' : normalized.toStringAsFixed(1);
  if (isChineseLocale(context)) {
    final unit = normalized == 1 ? singularZh : pluralZh;
    return '$display$unit';
  }
  final unit = normalized == 1 ? singularEn : pluralEn;
  return '$display $unit';
}

String _formatMinutes(BuildContext context, int minutes) {
  final normalized = minutes < 0 ? 0 : minutes;
  final hours = normalized ~/ 60;
  final remainingMinutes = normalized % 60;
  if (isChineseLocale(context)) {
    if (hours == 0) {
      return '$remainingMinutes 分钟';
    }
    if (remainingMinutes == 0) {
      return '$hours 小时';
    }
    return '$hours 小时 $remainingMinutes 分钟';
  }
  if (hours == 0) {
    return '$remainingMinutes min';
  }
  if (remainingMinutes == 0) {
    return '$hours h';
  }
  return '$hours h $remainingMinutes min';
}
