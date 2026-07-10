import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

class TeamWorkspaceSnapshot {
  const TeamWorkspaceSnapshot({
    required this.teamOverview,
    required this.friendOverview,
    required this.teamChatOverview,
    this.bannerMessage,
  });

  final TeamOverview teamOverview;
  final FriendOverview friendOverview;
  final TeamChatOverview teamChatOverview;
  final String? bannerMessage;
}
