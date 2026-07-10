import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({
    super.key,
    required this.initialOverview,
    required this.onRefresh,
    required this.onSearch,
    required this.onSendFriendRequest,
    required this.onRespondFriendRequest,
    required this.onCreateGroup,
    required this.onMoveFriendToGroup,
    required this.onDeleteFriend,
  });

  final FriendOverview initialOverview;
  final Future<FriendOverview?> Function() onRefresh;
  final Future<List<FriendSearchItemModel>> Function(String keyword) onSearch;
  final Future<FriendOverview?> Function(
    int targetUserId, {
    String message,
  }) onSendFriendRequest;
  final Future<FriendOverview?> Function(
    int requestId, {
    required bool accept,
  }) onRespondFriendRequest;
  final Future<FriendOverview?> Function(String groupName) onCreateGroup;
  final Future<FriendOverview?> Function(
    int friendUserId, {
    required int groupId,
  }) onMoveFriendToGroup;
  final Future<FriendOverview?> Function(int friendUserId) onDeleteFriend;

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  late FriendOverview _overview;
  bool _isLoading = false;
  String _searchKeyword = '';
  List<FriendSearchItemModel> _searchResults = const [];

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _overview = widget.initialOverview;
  }

  Future<void> _refresh() async {
    await _runOverviewAction(
      widget.onRefresh,
      fallbackMessage:
          _text('当前无法刷新好友数据。', 'Unable to refresh friends right now.'),
    );
  }

  Future<void> _search() async {
    final controller = TextEditingController(text: _searchKeyword);
    final keyword = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('搜索用户', 'Search users')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _text('用户号或昵称', 'User No or nickname'),
              hintText: _text('按用户号或昵称搜索', 'Search by user number or nickname'),
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
              child: Text(_text('搜索', 'Search')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (keyword == null || keyword.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final items = await widget.onSearch(keyword);
      if (!mounted) {
        return;
      }
      setState(() {
        _searchKeyword = keyword;
        _searchResults = items;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendRequest(FriendSearchItemModel item) async {
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('发送好友申请', 'Send friend request')),
          content: TextField(
            controller: controller,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: _text('留言', 'Message'),
              hintText: _text('向 ${item.displayName} 打个招呼',
                  'Say hello to ${item.displayName}'),
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
              child: Text(_text('发送', 'Send')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (message == null) {
      return;
    }

    await _runOverviewAction(
      () => widget.onSendFriendRequest(item.userId, message: message),
      fallbackMessage:
          _text('当前无法发送好友申请。', 'Unable to send the friend request.'),
    );

    if (!mounted || _searchKeyword.isEmpty) {
      return;
    }
    try {
      final items = await widget.onSearch(_searchKeyword);
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = items;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text('当前无法刷新搜索结果。', 'Unable to refresh search results.'),
          ),
        ),
      );
    }
  }

  Future<void> _respondRequest(FriendRequestModel request, bool accept) async {
    await _runOverviewAction(
      () => widget.onRespondFriendRequest(request.requestId, accept: accept),
      fallbackMessage:
          _text('当前无法处理好友申请。', 'Unable to respond to the friend request.'),
    );
  }

  Future<void> _createGroup() async {
    final controller = TextEditingController();
    final groupName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('新建好友分组', 'Create friend group')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: _text('分组名称', 'Group name'),
              hintText: _text(
                  '例如：同学、家人、挚友', 'For example: School, Family, Close friends'),
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
              child: Text(_text('创建', 'Create')),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (groupName == null || groupName.isEmpty) {
      return;
    }

    await _runOverviewAction(
      () => widget.onCreateGroup(groupName),
      fallbackMessage:
          _text('当前无法创建好友分组。', 'Unable to create the friend group.'),
    );
  }

  Future<void> _moveFriend(FriendItemModel friend) async {
    final nextGroupId = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('移动到分组', 'Move to group')),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _overview.groups.map((group) {
                  return ListTile(
                    title: Text(group.groupName),
                    subtitle: Text(
                      _isChinese
                          ? '${group.friendCount} 位好友'
                          : '${group.friendCount} friends',
                    ),
                    trailing: group.groupId == friend.groupId
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(context).pop(group.groupId),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );

    if (nextGroupId == null || nextGroupId == friend.groupId) {
      return;
    }

    await _runOverviewAction(
      () => widget.onMoveFriendToGroup(friend.userId, groupId: nextGroupId),
      fallbackMessage: _text('当前无法移动好友。', 'Unable to move the friend.'),
    );
  }

  Future<void> _deleteFriend(FriendItemModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text('删除好友', 'Remove friend')),
          content: Text(
            _text(
              '确认将 ${friend.displayName} 从好友列表中删除吗？这也会清除双方之间的待处理申请。',
              'Remove ${friend.displayName} from your friend list? This also clears pending requests between you.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text('取消', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text('删除', 'Remove')),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _runOverviewAction(
      () => widget.onDeleteFriend(friend.userId),
      fallbackMessage: _text('当前无法删除好友。', 'Unable to remove the friend.'),
    );
  }

  Future<void> _runOverviewAction(
    Future<FriendOverview?> Function() action, {
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
      title: _text('好友中心', 'Friend center'),
      description: _text(
        '在这里搜索用户、处理好友申请、管理分组，并保持一个熟人小圈子。',
        'Search, send requests, group friends, and keep your circle small and trusted.',
      ),
      headerActions: [
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _search,
          icon: const Icon(Icons.search_rounded),
          label: Text(_text('搜索用户', 'Search users')),
        ),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _createGroup,
          icon: const Icon(Icons.create_new_folder_rounded),
          label: Text(_text('新建分组', 'New group')),
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
          child: _FriendHeroCard(
            overview: _overview,
            isChinese: _isChinese,
          ),
        ),
        if (_searchKeyword.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassPanel(
            lightStyle: true,
            child: _SearchResultCard(
              keyword: _searchKeyword,
              items: _searchResults,
              onSendRequest: _sendRequest,
              isChinese: _isChinese,
            ),
          ),
        ],
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _RequestCard(
            overview: _overview,
            onRespond: _respondRequest,
            isChinese: _isChinese,
          ),
        ),
        const SizedBox(height: 16),
        GlassPanel(
          lightStyle: true,
          child: _FriendGroupCard(
            overview: _overview,
            onMoveFriend: _moveFriend,
            onDeleteFriend: _deleteFriend,
            isChinese: _isChinese,
          ),
        ),
      ],
    );
  }
}

class _FriendHeroCard extends StatelessWidget {
  const _FriendHeroCard({
    required this.overview,
    required this.isChinese,
  });

  final FriendOverview overview;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('熟人圈概览', 'Trusted-circle overview'),
            style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          _text(
            '${overview.friendCount}/${overview.maxFriendCount} 位好友  |  ${overview.groups.length} 个分组  |  ${overview.incomingRequests.length} 条待处理申请',
            '${overview.friendCount}/${overview.maxFriendCount} friends  |  ${overview.groups.length} groups  |  ${overview.incomingRequests.length} waiting for your reply',
          ),
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: overview.groups.isEmpty
              ? [
                  _FriendTag(
                    label: _text('系统会自动创建默认分组',
                        'Default group will be created automatically'),
                  ),
                ]
              : overview.groups
                  .map((group) => _FriendTag(
                        label: isChinese
                            ? '${group.groupName}（${group.friendCount}）'
                            : '${group.groupName} (${group.friendCount})',
                      ))
                  .toList(),
        ),
      ],
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.keyword,
    required this.items,
    required this.onSendRequest,
    required this.isChinese,
  });

  final String keyword;
  final List<FriendSearchItemModel> items;
  final Future<void> Function(FriendSearchItemModel item) onSendRequest;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  String _displayName(FriendSearchItemModel item) {
    if (item.nickname.trim().isNotEmpty) {
      return item.nickname.trim();
    }
    if (item.userNo.trim().isNotEmpty) {
      return item.userNo.trim();
    }
    return _text('用户', 'User');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _text('“$keyword”的搜索结果', 'Search results for "$keyword"'),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            _text('没有找到匹配的用户。', 'No matching users were found.'),
            style: textTheme.bodyLarge,
          )
        else
          ...items.map((item) {
            final disabled = item.alreadyFriend ||
                item.outgoingPending ||
                item.blockedByMe ||
                item.blockedMe;
            final label = item.alreadyFriend
                ? _text('已经是好友', 'Already friends')
                : item.outgoingPending
                    ? _text('已发送申请', 'Request sent')
                    : item.incomingPending
                        ? _text('等待处理', 'Waiting for reply')
                        : item.blockedByMe
                            ? _text('你已拉黑', 'Blocked by you')
                            : item.blockedMe
                                ? _text('无法添加', 'Unavailable')
                                : _text('添加好友', 'Add friend');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SurfacePalette.softSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SurfacePalette.border),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(item),
                          style: textTheme.titleMedium?.copyWith(
                            color: SurfacePalette.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.userNo.isEmpty
                              ? _text('暂无用户号', 'No user number')
                              : item.userNo,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (item.sameTeam)
                              _FriendTag(label: _text('同团队', 'Same team')),
                            if (item.incomingPending)
                              _FriendTag(
                                  label: _text('收到申请', 'Incoming request')),
                          ],
                        ),
                      ],
                    ),
                    FilledButton.icon(
                      onPressed: disabled || item.incomingPending
                          ? null
                          : () async {
                              await onSendRequest(item);
                            },
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(label),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.overview,
    required this.onRespond,
    required this.isChinese,
  });

  final FriendOverview overview;
  final Future<void> Function(FriendRequestModel request, bool accept)
      onRespond;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('好友申请', 'Requests'), style: textTheme.titleMedium),
        const SizedBox(height: 12),
        if (!overview.hasPendingRequests)
          Text(
            _text('当前没有待处理的好友申请。', 'No pending friend requests right now.'),
            style: textTheme.bodyLarge,
          )
        else ...[
          if (overview.incomingRequests.isNotEmpty) ...[
            Text(_text('收到的申请', 'Incoming'), style: textTheme.titleSmall),
            const SizedBox(height: 10),
            ...overview.incomingRequests.map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestTile(
                  request: request,
                  isChinese: isChinese,
                  trailing: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await onRespond(request, false);
                        },
                        child: Text(_text('拒绝', 'Decline')),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await onRespond(request, true);
                        },
                        child: Text(_text('同意', 'Accept')),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (overview.outgoingRequests.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_text('已发出的申请', 'Outgoing'), style: textTheme.titleSmall),
            const SizedBox(height: 10),
            ...overview.outgoingRequests.map((request) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _RequestTile(
                  request: request,
                  isChinese: isChinese,
                  trailing: _FriendTag(label: _text('等待中', 'Waiting')),
                ),
              );
            }),
          ],
        ],
      ],
    );
  }
}

class _FriendGroupCard extends StatelessWidget {
  const _FriendGroupCard({
    required this.overview,
    required this.onMoveFriend,
    required this.onDeleteFriend,
    required this.isChinese,
  });

  final FriendOverview overview;
  final Future<void> Function(FriendItemModel friend) onMoveFriend;
  final Future<void> Function(FriendItemModel friend) onDeleteFriend;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  String _displayName(FriendItemModel friend) {
    if (friend.nickname.trim().isNotEmpty) {
      return friend.nickname.trim();
    }
    if (friend.userNo.trim().isNotEmpty) {
      return friend.userNo.trim();
    }
    return _text('好友', 'Friend');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_text('好友分组', 'Friend groups'), style: textTheme.titleMedium),
        const SizedBox(height: 12),
        if (!overview.hasFriends)
          Text(
            _text(
              '还没有好友，先通过用户号或昵称开始建立你的熟人圈。',
              'No friends yet. Search by user number or nickname to start building the circle.',
            ),
            style: textTheme.bodyLarge,
          )
        else
          ...overview.groups.map((group) {
            final items = overview.friendsInGroup(group.groupId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Text(
                        group.groupName,
                        style: textTheme.titleMedium?.copyWith(
                          color: SurfacePalette.ink,
                        ),
                      ),
                      _FriendTag(
                        label: _text(
                            '${items.length} 位好友', '${items.length} friends'),
                      ),
                      if (group.system)
                        _FriendTag(label: _text('默认', 'Default')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (items.isEmpty)
                    Text(
                      _text('这个分组里还没有好友。', 'No friends in this group yet.'),
                      style: textTheme.bodyMedium,
                    )
                  else
                    ...items.map((friend) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SurfacePalette.softSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: SurfacePalette.border),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 520),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayName(friend),
                                      style: textTheme.titleMedium?.copyWith(
                                        color: SurfacePalette.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      friend.userNo.isEmpty
                                          ? _text('暂无用户号', 'No user number')
                                          : friend.userNo,
                                      style: textTheme.bodyMedium,
                                    ),
                                    if (friend.profileVisible &&
                                        friend.bio.trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(friend.bio,
                                          style: textTheme.bodyMedium),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _FriendTag(label: friend.groupName),
                                        _FriendTag(
                                          label: friend.profileVisible
                                              ? _text('资料可见', 'Profile visible')
                                              : _text('资料隐藏', 'Profile hidden'),
                                        ),
                                        if (friend.sameTeam)
                                          _FriendTag(
                                              label: _text('同团队', 'Same team')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () async {
                                      await onMoveFriend(friend);
                                    },
                                    child: Text(_text('移动', 'Move')),
                                  ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await onDeleteFriend(friend);
                                    },
                                    child: Text(_text('删除', 'Remove')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.trailing,
    required this.isChinese,
  });

  final FriendRequestModel request;
  final Widget trailing;
  final bool isChinese;

  String _text(String zh, String en) => isChinese ? zh : en;

  String _displayName(FriendRequestModel request) {
    if (request.nickname.trim().isNotEmpty) {
      return request.nickname.trim();
    }
    if (request.userNo.trim().isNotEmpty) {
      return request.userNo.trim();
    }
    return _text('用户', 'User');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName(request),
                style: textTheme.titleMedium?.copyWith(
                  color: SurfacePalette.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                request.userNo.isEmpty
                    ? _text('暂无用户号', 'No user number')
                    : request.userNo,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                request.requestMessage.isEmpty
                    ? _text('没有附带留言。', 'No message attached.')
                    : request.requestMessage,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FriendTag(label: request.createTime),
                  if (request.sameTeam)
                    _FriendTag(label: _text('同团队', 'Same team')),
                ],
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}

class _FriendTag extends StatelessWidget {
  const _FriendTag({required this.label});

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
