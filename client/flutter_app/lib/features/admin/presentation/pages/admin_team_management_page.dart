import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/admin/presentation/utils/admin_label_localizer.dart';

class AdminTeamManagementPage extends StatefulWidget {
  const AdminTeamManagementPage({
    super.key,
    required this.onLoadTeams,
    required this.onLoadTeamDetail,
    required this.onRemoveMember,
    required this.onDissolveTeam,
  });

  final Future<List<AdminTeamListItem>> Function({
    String keyword,
    int? status,
    int limit,
  }) onLoadTeams;
  final Future<AdminTeamDetail?> Function(int teamId) onLoadTeamDetail;
  final Future<AdminTeamActionResult?> Function(
    int teamId, {
    required int memberUserId,
  }) onRemoveMember;
  final Future<AdminTeamActionResult?> Function(int teamId) onDissolveTeam;

  @override
  State<AdminTeamManagementPage> createState() =>
      _AdminTeamManagementPageState();
}

class _AdminTeamManagementPageState extends State<AdminTeamManagementPage> {
  late final TextEditingController _searchController;
  List<AdminTeamListItem> _teams = const [];
  bool _isLoading = true;
  int? _statusFilter = 1;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  String _teamStatusLabel(String value) =>
      localizeAdminTeamStatus(context, value);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _refresh();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final teams = await widget.onLoadTeams(
        keyword: _searchController.text.trim(),
        status: _statusFilter,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _teams = teams;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openTeam(AdminTeamListItem item) async {
    final detail = await widget.onLoadTeamDetail(item.teamId);
    if (!mounted || detail == null) {
      return;
    }

    final changed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _AdminTeamDetailDialog(
          detail: detail,
          isChinese: _isChinese,
          onRemoveMember: (memberUserId) async {
            final result = await widget.onRemoveMember(
              item.teamId,
              memberUserId: memberUserId,
            );
            return result?.success == true;
          },
          onDissolveTeam: () async {
            final result = await widget.onDissolveTeam(item.teamId);
            return result?.success == true;
          },
        );
      },
    );
    if (changed == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('团队管理', 'Team management'),
      description: _text(
        '查看团队状态、队员进度，并在需要时移除成员或解散团队。',
        'Review team status, inspect member progress, remove members, and dissolve teams when needed.',
      ),
      headerActions: [
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
        GlassPanel(
          lightStyle: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _refresh(),
                decoration: InputDecoration(
                  labelText: _text(
                    '按团队名、邀请码或队长搜索',
                    'Search by team name, invite code, or owner',
                  ),
                  suffixIcon: IconButton(
                    onPressed: _isLoading ? null : _refresh,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SegmentedButton<int?>(
                segments: [
                  ButtonSegment<int?>(
                    value: 1,
                    label: Text(_text('进行中', 'Active')),
                  ),
                  ButtonSegment<int?>(
                    value: 0,
                    label: Text(_text('已解散', 'Dissolved')),
                  ),
                  ButtonSegment<int?>(
                    value: null,
                    label: Text(_text('全部', 'All')),
                  ),
                ],
                selected: {_statusFilter},
                onSelectionChanged: _isLoading
                    ? null
                    : (selection) async {
                        setState(() {
                          _statusFilter = selection.first;
                        });
                        await _refresh();
                      },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_teams.isEmpty)
          GlassPanel(
            lightStyle: true,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isLoading
                    ? _text('正在加载团队数据...', 'Loading teams...')
                    : _text(
                        '当前筛选条件下没有团队。', 'No teams matched the current filter.'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          ..._teams.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassPanel(
                lightStyle: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async => _openTeam(item),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _AdminTag(
                                label: _teamStatusLabel(item.statusLabel)),
                            _AdminTag(
                              label: _text(
                                '${item.memberCount}/5 人',
                                '${item.memberCount}/5 members',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.teamName.isEmpty
                              ? _text('未命名团队', 'Unnamed team')
                              : item.teamName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SurfacePalette.ink,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _text(
                            '队长：${item.ownerDisplayName.isEmpty ? '未知' : item.ownerDisplayName}\n邀请码：${item.inviteCode.isEmpty ? '未知' : item.inviteCode}',
                            'Owner: ${item.ownerDisplayName.isEmpty ? 'Unknown' : item.ownerDisplayName}\nInvite code: ${item.inviteCode.isEmpty ? 'Unknown' : item.inviteCode}',
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

class _AdminTeamDetailDialog extends StatefulWidget {
  const _AdminTeamDetailDialog({
    required this.detail,
    required this.isChinese,
    required this.onRemoveMember,
    required this.onDissolveTeam,
  });

  final AdminTeamDetail detail;
  final bool isChinese;
  final Future<bool> Function(int memberUserId) onRemoveMember;
  final Future<bool> Function() onDissolveTeam;

  @override
  State<_AdminTeamDetailDialog> createState() => _AdminTeamDetailDialogState();
}

class _AdminTeamDetailDialogState extends State<_AdminTeamDetailDialog> {
  bool _isSubmitting = false;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  String _teamStatusLabel(String value) =>
      localizeAdminTeamStatus(context, value);

  String _teamRoleLabel(String value) => localizeAdminTeamRole(context, value);

  Future<void> _removeMember(AdminTeamMember member) async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final success = await widget.onRemoveMember(member.userId);
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

  Future<void> _dissolveTeam() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final success = await widget.onDissolveTeam();
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

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassPanel(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 820),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _AdminTag(label: _teamStatusLabel(detail.statusLabel)),
                    _AdminTag(
                      label: _text(
                        '${detail.memberCount}/${detail.memberLimit} 人',
                        '${detail.memberCount}/${detail.memberLimit} members',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  detail.teamName.isEmpty
                      ? _text('未命名团队', 'Unnamed team')
                      : detail.teamName,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  _text(
                    '队长：${detail.ownerDisplayName.isEmpty ? '未知' : detail.ownerDisplayName}\n邀请码：${detail.inviteCode.isEmpty ? '未知' : detail.inviteCode}\n创建时间：${detail.createTime.isEmpty ? '未知' : detail.createTime}',
                    'Owner: ${detail.ownerDisplayName.isEmpty ? 'Unknown' : detail.ownerDisplayName}\nInvite code: ${detail.inviteCode.isEmpty ? 'Unknown' : detail.inviteCode}\nCreated: ${detail.createTime.isEmpty ? 'Unknown' : detail.createTime}',
                  ),
                  style: textTheme.bodyMedium,
                ),
                if (detail.latestChatPreview.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(_text('最近群聊预览', 'Latest chat preview'),
                      style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(detail.latestChatPreview, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: 18),
                Text(_text('团队成员', 'Members'), style: textTheme.titleLarge),
                const SizedBox(height: 10),
                ...detail.members.map(
                  (member) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SurfacePalette.softSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: SurfacePalette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 10,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _AdminTag(
                                  label: member.owner
                                      ? _teamRoleLabel('owner')
                                      : _teamRoleLabel('member'),
                                ),
                                if (member.activeStudy)
                                  _AdminTag(label: _text('学习中', 'studying')),
                              ],
                            ),
                            if (!member.owner && detail.statusCode == 1)
                              FilledButton.tonalIcon(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async => _removeMember(member),
                                icon: const Icon(
                                    Icons.person_remove_alt_1_rounded),
                                label: Text(_text('移除', 'Remove')),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          member.displayName,
                          style: textTheme.titleMedium?.copyWith(
                            color: SurfacePalette.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _text(
                            '今日计划：${member.todayCompletedCount}/${member.todayTotalCount}\n今日学习：${member.todayStudyDurationMinutes} 分钟\n累计学习：${member.totalStudyDurationMinutes} 分钟\n累计签到：${member.totalCheckInDays} 天',
                            'Today plan: ${member.todayCompletedCount}/${member.todayTotalCount}\nToday study: ${member.todayStudyDurationMinutes} min\nTotal study: ${member.totalStudyDurationMinutes} min\nCheck-in total: ${member.totalCheckInDays} days',
                          ),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(_text('关闭', 'Close')),
                    ),
                    if (detail.statusCode == 1) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _isSubmitting ? null : _dissolveTeam,
                        icon: _isSubmitting
                            ? const SizedBox.square(
                                dimension: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_sweep_rounded),
                        label: Text(_text('解散团队', 'Dissolve team')),
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
