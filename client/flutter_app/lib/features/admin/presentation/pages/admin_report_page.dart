import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/admin/presentation/utils/admin_label_localizer.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({
    super.key,
    required this.onLoadReports,
    required this.onLoadDetail,
    required this.onReview,
  });

  final Future<List<AdminReportListItem>> Function({
    String status,
    String reportType,
    int limit,
  }) onLoadReports;
  final Future<AdminReportDetail?> Function(int reportId) onLoadDetail;
  final Future<AdminReportReviewResult?> Function(
    int reportId, {
    required String decision,
    required bool deleteContent,
    required String punishmentType,
    required int durationDays,
    required String reason,
  }) onReview;

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  List<AdminReportListItem> _reports = const [];
  String _status = 'pending';
  bool _isLoading = true;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  String _statusLabel(String value) =>
      localizeAdminReportStatus(context, value);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final reports = await widget.onLoadReports(status: _status);
      if (!mounted) {
        return;
      }
      setState(() {
        _reports = reports;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openDetail(AdminReportListItem item) async {
    final detail = await widget.onLoadDetail(item.reportId);
    if (!mounted || detail == null) {
      return;
    }

    final reviewed = await showDialog<bool>(
      context: context,
      builder: (context) => _AdminReportDetailDialog(
        detail: detail,
        isChinese: _isChinese,
        onReview: (draft) async {
          final result = await widget.onReview(
            detail.reportId,
            decision: draft.decision,
            deleteContent: draft.deleteContent,
            punishmentType: draft.punishmentType,
            durationDays: draft.durationDays,
            reason: draft.reason,
          );
          return result != null;
        },
      ),
    );
    if (reviewed == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('举报审核', 'Report moderation'),
      description: _text(
        '审核熟人圈团队交流中的举报内容，并执行删除、警告、禁言或封号等处理。',
        'Review trusted-circle team chat reports, remove content, and apply basic penalties.',
      ),
      headerActions: [
        SegmentedButton<String>(
          segments: [
            ButtonSegment<String>(
              value: 'pending',
              label: Text(_text('待处理', 'Pending')),
            ),
            ButtonSegment<String>(
              value: 'resolved',
              label: Text(_text('已处理', 'Resolved')),
            ),
            ButtonSegment<String>(
              value: 'rejected',
              label: Text(_text('已驳回', 'Rejected')),
            ),
          ],
          selected: {_status},
          onSelectionChanged: _isLoading
              ? null
              : (selection) async {
                  setState(() {
                    _status = selection.first;
                  });
                  await _refresh();
                },
        ),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _refresh,
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(_text('刷新', 'Refresh')),
        ),
      ],
      children: [
        if (_reports.isEmpty)
          GlassPanel(
            lightStyle: true,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isLoading
                    ? _text('正在加载举报数据...', 'Loading reports...')
                    : _text(
                        '当前筛选条件下没有举报记录。', 'No reports in the current filter.'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          ..._reports.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassPanel(
                lightStyle: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async => _openDetail(item),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _AdminTag(label: _statusLabel(item.status)),
                            _AdminTag(label: item.reason),
                            if (item.targetDeleted)
                              _AdminTag(
                                  label: _text('内容已删除', 'Content removed')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.contentPreview.isEmpty
                              ? _text('暂无内容预览', 'No content preview')
                              : item.contentPreview,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SurfacePalette.ink,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _text(
                            '举报人：${item.reportUserDisplayName}  |  被举报人：${item.targetUserDisplayName}  |  团队：${item.teamName.isEmpty ? '未知团队' : item.teamName}',
                            'Reporter: ${item.reportUserDisplayName}  |  Target: ${item.targetUserDisplayName}  |  Team: ${item.teamName.isEmpty ? 'Unknown team' : item.teamName}',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.createTime,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminReportDetailDialog extends StatefulWidget {
  const _AdminReportDetailDialog({
    required this.detail,
    required this.isChinese,
    required this.onReview,
  });

  final AdminReportDetail detail;
  final bool isChinese;
  final Future<bool> Function(_ReviewDraft draft) onReview;

  @override
  State<_AdminReportDetailDialog> createState() =>
      _AdminReportDetailDialogState();
}

class _AdminReportDetailDialogState extends State<_AdminReportDetailDialog> {
  bool _isSubmitting = false;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  String _statusLabel(String value) =>
      localizeAdminReportStatus(context, value);

  String _decisionLabel(String value) =>
      localizeAdminReviewDecision(context, value);

  String _punishmentLabel(String value) =>
      localizeAdminPunishmentType(context, value);

  Future<void> _review() async {
    final draft = await showDialog<_ReviewDraft>(
      context: context,
      builder: (context) => _ReviewDialog(isChinese: widget.isChinese),
    );
    if (draft == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    try {
      final success = await widget.onReview(draft);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(success);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final textTheme = Theme.of(context).textTheme;
    final canReview = detail.status == 'pending';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AdminTag(label: _statusLabel(detail.status)),
                    _AdminTag(label: detail.reason),
                  ],
                ),
                const SizedBox(height: 14),
                Text(_text('被举报内容', 'Reported content'),
                    style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SurfacePalette.softSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SurfacePalette.border),
                  ),
                  child: Text(
                    detail.targetContent.isEmpty
                        ? _text('暂无可查看内容。', 'No content available.')
                        : detail.targetContent,
                    style: textTheme.bodyLarge?.copyWith(
                      color: SurfacePalette.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _text(
                    '举报人：${detail.reportUserDisplayName}\n被举报人：${detail.targetUserDisplayName}\n团队：${detail.teamName.isEmpty ? '未知团队' : detail.teamName}\n创建时间：${detail.createTime}',
                    'Reporter: ${detail.reportUserDisplayName}\nTarget: ${detail.targetUserDisplayName}\nTeam: ${detail.teamName.isEmpty ? 'Unknown team' : detail.teamName}\nCreated: ${detail.createTime}',
                  ),
                  style: textTheme.bodyMedium,
                ),
                if (detail.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(_text('举报备注', 'Reporter note'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(detail.description, style: textTheme.bodyMedium),
                ],
                if (detail.auditHistory.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(_text('审核记录', 'Audit history'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ...detail.auditHistory.map(
                    (item) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SurfacePalette.softSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _text(
                          '${item.createTime}  |  ${item.adminDisplayName}\n结论：${_decisionLabel(item.decision)}  |  处罚：${_punishmentLabel(item.punishmentType)}\n${item.reason}',
                          '${item.createTime}  |  ${item.adminDisplayName}\nDecision: ${_decisionLabel(item.decision)}  |  Penalty: ${_punishmentLabel(item.punishmentType)}\n${item.reason}',
                        ),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(_text('关闭', 'Close')),
                    ),
                    if (canReview) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _review,
                        icon: _isSubmitting
                            ? const SizedBox.square(
                                dimension: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.gavel_rounded),
                        label: Text(_text('审核', 'Review')),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewDraft {
  const _ReviewDraft({
    required this.decision,
    required this.deleteContent,
    required this.punishmentType,
    required this.durationDays,
    required this.reason,
  });

  final String decision;
  final bool deleteContent;
  final String punishmentType;
  final int durationDays;
  final String reason;
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.isChinese});

  final bool isChinese;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  String _decision = 'violation';
  bool _deleteContent = true;
  String _punishmentType = 'warn';
  int _durationDays = 3;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final requiresDays = _punishmentType == 'mute' || _punishmentType == 'ban';
    String text(String zh, String en) => widget.isChinese ? zh : en;

    return AlertDialog(
      title: Text(text('审核举报', 'Review report')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _decision,
                decoration:
                    InputDecoration(labelText: text('审核结论', 'Decision')),
                items: [
                  DropdownMenuItem(
                    value: 'violation',
                    child: Text(text('确认违规', 'Violation confirmed')),
                  ),
                  DropdownMenuItem(
                    value: 'reject',
                    child: Text(text('驳回举报', 'Reject report')),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _decision = value;
                    if (_decision == 'reject') {
                      _deleteContent = false;
                      _punishmentType = 'none';
                    } else if (_punishmentType == 'none') {
                      _punishmentType = 'warn';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _deleteContent,
                onChanged: _decision == 'reject'
                    ? null
                    : (value) {
                        setState(() {
                          _deleteContent = value;
                        });
                      },
                title: Text(text('删除内容', 'Delete content')),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _punishmentType,
                decoration:
                    InputDecoration(labelText: text('处罚方式', 'Punishment')),
                items: [
                  DropdownMenuItem(
                      value: 'none', child: Text(text('无', 'None'))),
                  DropdownMenuItem(
                      value: 'warn', child: Text(text('警告', 'Warn'))),
                  DropdownMenuItem(
                      value: 'mute', child: Text(text('禁言', 'Mute'))),
                  DropdownMenuItem(
                      value: 'ban', child: Text(text('封号', 'Ban'))),
                ],
                onChanged: _decision == 'reject'
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _punishmentType = value;
                        });
                      },
              ),
              if (requiresDays) ...[
                const SizedBox(height: 12),
                Text(
                  text('处罚天数：$_durationDays', 'Duration days: $_durationDays'),
                  style: textTheme.bodyMedium,
                ),
                Slider(
                  value: _durationDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$_durationDays',
                  onChanged: (value) {
                    setState(() {
                      _durationDays = value.round();
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _reasonController,
                maxLength: 255,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: text('原因说明', 'Reason'),
                  hintText: text(
                    '填写处理原因，便于记录和后续通知用户。',
                    'Explain the review result for the record and user notice.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(text('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _ReviewDraft(
                decision: _decision,
                deleteContent: _deleteContent,
                punishmentType: _punishmentType,
                durationDays: requiresDays ? _durationDays : 0,
                reason: _reasonController.text.trim(),
              ),
            );
          },
          child: Text(text('提交', 'Submit')),
        ),
      ],
    );
  }
}

class _AdminTag extends StatelessWidget {
  const _AdminTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
