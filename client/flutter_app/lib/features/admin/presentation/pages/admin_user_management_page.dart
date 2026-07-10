import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';
import 'package:innocence_flutter/features/admin/presentation/utils/admin_label_localizer.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({
    super.key,
    required this.onSearchUsers,
    required this.onLoadUserDetail,
    required this.onLoadUserReports,
    required this.onLoadUserPunishments,
    required this.onLiftPunishment,
  });

  final Future<List<AdminUserSearchItem>> Function({
    String keyword,
    int limit,
  }) onSearchUsers;
  final Future<AdminUserDetail?> Function(int userId) onLoadUserDetail;
  final Future<List<AdminUserReportItem>> Function(
    int userId, {
    int limit,
  }) onLoadUserReports;
  final Future<List<AdminUserPunishmentItem>> Function(
    int userId, {
    String status,
    int limit,
  }) onLoadUserPunishments;
  final Future<AdminLiftPunishmentResult?> Function(
    int userId, {
    required int punishmentId,
  }) onLiftPunishment;

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  late final TextEditingController _searchController;
  List<AdminUserSearchItem> _items = const [];
  bool _isLoading = true;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  String _userStatusLabel(String value) =>
      localizeAdminUserStatus(context, value);

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
      final items = await widget.onSearchUsers(
        keyword: _searchController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openUser(AdminUserSearchItem item) async {
    final detail = await widget.onLoadUserDetail(item.userId);
    if (!mounted || detail == null) {
      return;
    }

    final reports = await widget.onLoadUserReports(item.userId);
    if (!mounted) {
      return;
    }
    final activePunishments = await widget.onLoadUserPunishments(
      item.userId,
      status: 'active',
    );
    if (!mounted) {
      return;
    }
    final historyPunishments = await widget.onLoadUserPunishments(
      item.userId,
      status: 'history',
    );
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return _AdminUserDetailDialog(
          detail: detail,
          reports: reports,
          activePunishments: activePunishments,
          historyPunishments: historyPunishments,
          isChinese: _isChinese,
          onLiftPunishment: (punishmentId) => widget.onLiftPunishment(
            item.userId,
            punishmentId: punishmentId,
          ),
        );
      },
    );
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('用户管理', 'User management'),
      description: _text(
        '搜索用户、查看资料与团队状态、审核历史，并解除正在生效的处罚。',
        'Search users, inspect profile and team state, review report history, and lift active penalties.',
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
                    '按用户号、昵称或邀请码搜索',
                    'Search by user no, nickname, or invite code',
                  ),
                  suffixIcon: IconButton(
                    onPressed: _isLoading ? null : _refresh,
                    icon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _text(
                    '留空可查看最近用户。', 'Leave it empty to browse the latest users.'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_items.isEmpty)
          GlassPanel(
            lightStyle: true,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isLoading
                    ? _text('正在加载用户...', 'Loading users...')
                    : _text('当前搜索条件下没有匹配用户。',
                        'No users matched the current search.'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassPanel(
                lightStyle: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async => _openUser(item),
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
                                label: _userStatusLabel(item.statusLabel)),
                            if (item.teamName.isNotEmpty)
                              _AdminTag(label: item.teamName),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.displayName.isEmpty
                              ? item.userNo
                              : item.displayName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: SurfacePalette.ink,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _text(
                            '用户号：${item.userNo.isEmpty ? '未知' : item.userNo}',
                            'User No: ${item.userNo.isEmpty ? 'Unknown' : item.userNo}',
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _text(
                            '最近登录：${item.lastLoginTime.isEmpty ? '暂无记录' : item.lastLoginTime}',
                            'Last login: ${item.lastLoginTime.isEmpty ? 'No record' : item.lastLoginTime}',
                          ),
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

class _AdminUserDetailDialog extends StatefulWidget {
  const _AdminUserDetailDialog({
    required this.detail,
    required this.reports,
    required this.activePunishments,
    required this.historyPunishments,
    required this.isChinese,
    required this.onLiftPunishment,
  });

  final AdminUserDetail detail;
  final List<AdminUserReportItem> reports;
  final List<AdminUserPunishmentItem> activePunishments;
  final List<AdminUserPunishmentItem> historyPunishments;
  final bool isChinese;
  final Future<AdminLiftPunishmentResult?> Function(int punishmentId)
      onLiftPunishment;

  @override
  State<_AdminUserDetailDialog> createState() => _AdminUserDetailDialogState();
}

class _AdminUserDetailDialogState extends State<_AdminUserDetailDialog> {
  bool _isLifting = false;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  String _userStatusLabel(String value) =>
      localizeAdminUserStatus(context, value);

  String _teamRoleLabel(String value) => localizeAdminTeamRole(context, value);

  String _reportStatusLabel(String value) =>
      localizeAdminReportStatus(context, value);

  Future<void> _lift(AdminUserPunishmentItem item) async {
    setState(() {
      _isLifting = true;
    });
    try {
      await widget.onLiftPunishment(item.punishmentId);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() {
          _isLifting = false;
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
        lightStyle: true,
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
                    _AdminTag(label: _userStatusLabel(detail.statusLabel)),
                    if (detail.teamName.isNotEmpty)
                      _AdminTag(label: detail.teamName),
                    if (detail.teamRole.isNotEmpty)
                      _AdminTag(label: _teamRoleLabel(detail.teamRole)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(detail.displayName, style: textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  _text(
                    '用户号：${detail.userNo.isEmpty ? '未知' : detail.userNo}\n邮箱：${detail.email.isEmpty ? '未知' : detail.email}\n创建时间：${detail.createTime.isEmpty ? '未知' : detail.createTime}\n最近登录：${detail.lastLoginTime.isEmpty ? '暂无记录' : detail.lastLoginTime}',
                    'User No: ${detail.userNo.isEmpty ? 'Unknown' : detail.userNo}\nEmail: ${detail.email.isEmpty ? 'Unknown' : detail.email}\nCreated: ${detail.createTime.isEmpty ? 'Unknown' : detail.createTime}\nLast login: ${detail.lastLoginTime.isEmpty ? 'No record' : detail.lastLoginTime}',
                  ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: _text('资料摘要', 'Profile summary')),
                _InfoGrid(
                  items: [
                    _InfoItem(
                      label: _text('累计学习', 'Study total'),
                      value: _text('${detail.totalStudyMinutes} 分钟',
                          '${detail.totalStudyMinutes} min'),
                    ),
                    _InfoItem(
                      label: _text('累计签到', 'Check-in total'),
                      value: _text('${detail.totalCheckInDays} 天',
                          '${detail.totalCheckInDays} days'),
                    ),
                    _InfoItem(
                      label: _text('当前连续', 'Current streak'),
                      value: _text('${detail.consecutiveCheckInDays} 天',
                          '${detail.consecutiveCheckInDays} days'),
                    ),
                    _InfoItem(
                      label: _text('时区', 'Timezone'),
                      value: detail.timezone.isEmpty
                          ? _text('未知', 'Unknown')
                          : detail.timezone,
                    ),
                    _InfoItem(
                      label: _text('好友资料可见', 'Friend profile view'),
                      value: detail.allowFriendViewProfile
                          ? _text('允许', 'Allowed')
                          : _text('隐藏', 'Hidden'),
                    ),
                    _InfoItem(
                      label: _text('队友学习可见', 'Teammate study view'),
                      value: detail.allowTeammateViewStudy
                          ? _text('允许', 'Allowed')
                          : _text('隐藏', 'Hidden'),
                    ),
                  ],
                ),
                if (detail.bio.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(_text('简介', 'Bio'), style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(detail.bio, style: textTheme.bodyMedium),
                ],
                const SizedBox(height: 18),
                _SectionTitle(title: _text('团队信息', 'Team')),
                Text(
                  detail.teamName.isEmpty
                      ? _text(
                          '该用户当前不在团队中。', 'The user is not currently in a team.')
                      : _text(
                          '团队：${detail.teamName}\n邀请码：${detail.teamInviteCode.isEmpty ? '未知' : detail.teamInviteCode}\n加入时间：${detail.teamJoinedTime.isEmpty ? '未知' : detail.teamJoinedTime}',
                          'Team: ${detail.teamName}\nInvite code: ${detail.teamInviteCode.isEmpty ? 'Unknown' : detail.teamInviteCode}\nJoined: ${detail.teamJoinedTime.isEmpty ? 'Unknown' : detail.teamJoinedTime}',
                        ),
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _SectionTitle(title: _text('当前处罚', 'Active punishments')),
                if (widget.activePunishments.isEmpty)
                  Text(_text('当前没有生效中的处罚。', 'No active punishments.'),
                      style: textTheme.bodyMedium)
                else
                  ...widget.activePunishments.map(
                    (item) => _PunishmentCard(
                      item: item,
                      isChinese: widget.isChinese,
                      onLift: item.liftable && !_isLifting
                          ? () => _lift(item)
                          : null,
                    ),
                  ),
                const SizedBox(height: 18),
                _SectionTitle(title: _text('处罚历史', 'Punishment history')),
                if (widget.historyPunishments.isEmpty)
                  Text(_text('没有历史处罚记录。', 'No past punishments.'),
                      style: textTheme.bodyMedium)
                else
                  ...widget.historyPunishments.map(
                    (item) => _PunishmentCard(
                      item: item,
                      isChinese: widget.isChinese,
                    ),
                  ),
                const SizedBox(height: 18),
                _SectionTitle(title: _text('举报记录', 'Report history')),
                if (widget.reports.isEmpty)
                  Text(_text('没有找到该用户相关举报。', 'No reports found for this user.'),
                      style: textTheme.bodyMedium)
                else
                  ...widget.reports.map(
                    (item) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SurfacePalette.softSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: SurfacePalette.border),
                      ),
                      child: Text(
                        _text(
                          '${item.createTime}  |  ${_reportStatusLabel(item.status)}\n原因：${item.reason}\n举报人：${item.reportUserDisplayName}\n${item.contentPreview.isEmpty ? '暂无内容预览。' : item.contentPreview}',
                          '${item.createTime}  |  ${_reportStatusLabel(item.status)}\nReason: ${item.reason}\nReporter: ${item.reportUserDisplayName}\n${item.contentPreview.isEmpty ? 'No content preview.' : item.contentPreview}',
                        ),
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_text('关闭', 'Close')),
                    ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: 200,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SurfacePalette.softSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SurfacePalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: SurfacePalette.ink,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _PunishmentCard extends StatelessWidget {
  const _PunishmentCard({
    required this.item,
    required this.isChinese,
    this.onLift,
  });

  final AdminUserPunishmentItem item;
  final bool isChinese;
  final VoidCallback? onLift;

  String _text(String zh, String en) => isChinese ? zh : en;

  String _punishmentLabel(BuildContext context, String value) =>
      localizeAdminPunishmentType(context, value);

  String _statusLabel(BuildContext context, String value) =>
      localizeAdminPunishmentStatus(context, value);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
                      label: _punishmentLabel(context, item.punishmentType)),
                  _AdminTag(label: _statusLabel(context, item.status)),
                  if (item.active)
                    _AdminTag(label: _text('当前生效', 'Active now')),
                ],
              ),
              if (onLift != null)
                FilledButton.tonalIcon(
                  onPressed: onLift,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: Text(_text('解除', 'Lift')),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _text(
              '执行人：${item.operatorDisplayName.isEmpty ? '管理员' : item.operatorDisplayName}\n开始时间：${item.startTime.isEmpty ? '未知' : item.startTime}\n结束时间：${item.endTime.isEmpty ? '无结束时间' : item.endTime}\n时长：${item.durationDays <= 0 ? '不固定' : '${item.durationDays} 天'}\n${item.reason.isEmpty ? '暂无记录原因。' : item.reason}',
              'Operator: ${item.operatorDisplayName.isEmpty ? 'Admin' : item.operatorDisplayName}\nStart: ${item.startTime.isEmpty ? 'Unknown' : item.startTime}\nEnd: ${item.endTime.isEmpty ? 'No end time' : item.endTime}\nDuration: ${item.durationDays <= 0 ? 'No fixed duration' : '${item.durationDays} days'}\n${item.reason.isEmpty ? 'No reason recorded.' : item.reason}',
            ),
            style: textTheme.bodyMedium,
          ),
        ],
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
