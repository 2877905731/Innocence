import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/team/domain/models/chat_report_result.dart';
import 'package:innocence_flutter/features/team/domain/models/team_chat_overview.dart';
import 'package:innocence_flutter/features/team/domain/models/team_overview.dart';

class TeamApi {
  TeamApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<TeamOverview> getCurrentTeam(AppSession session) async {
    final data = await _apiClient.get(
      'team/current',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the current team.');
    }
    return TeamOverview.fromJson(data);
  }

  Future<TeamOverview> createTeam(
    AppSession session, {
    required String teamName,
  }) async {
    final data = await _apiClient.post(
      'team/create',
      body: {'teamName': teamName},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to create the team.');
    }
    return TeamOverview.fromJson(data);
  }

  Future<TeamOverview> joinTeam(
    AppSession session, {
    required String inviteCode,
  }) async {
    final data = await _apiClient.post(
      'team/join',
      body: {'inviteCode': inviteCode},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to join the team.');
    }
    return TeamOverview.fromJson(data);
  }

  Future<TeamOverview> inviteMember(
    AppSession session, {
    required int targetUserId,
  }) async {
    final data = await _apiClient.post(
      'team/invite',
      body: {'targetUserId': targetUserId},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to send the team invitation.');
    }
    return TeamOverview.fromJson(data);
  }

  Future<TeamOverview> respondInvitation(
    AppSession session, {
    required int invitationId,
    required bool accept,
  }) async {
    final data = await _apiClient.post(
      'team/invitations/$invitationId/respond',
      body: {'accept': accept},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to respond to the team invitation.');
    }
    return TeamOverview.fromJson(data);
  }

  Future<bool> removeMember(
    AppSession session, {
    required int memberUserId,
  }) async {
    final data = await _apiClient.post(
      'team/remove-member?memberUserId=$memberUserId',
      headers: session.authHeaders,
    );
    if (data is bool) {
      return data;
    }
    return '$data' == 'true';
  }

  Future<bool> dissolveTeam(AppSession session) async {
    final data = await _apiClient.post(
      'team/dissolve',
      headers: session.authHeaders,
    );
    if (data is bool) {
      return data;
    }
    return '$data' == 'true';
  }

  Future<int?> remindTeammate(
    AppSession session, {
    required int teammateUserId,
  }) async {
    final data = await _apiClient.post(
      'team/teammates/remind?teammateUserId=$teammateUserId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to send the teammate reminder.');
    }
    final count = data['reminderCountToday'];
    if (count is int) {
      return count;
    }
    return int.tryParse('$count');
  }

  Future<TeamChatOverview> getTeamChat(
    AppSession session, {
    int limit = 50,
  }) async {
    final data = await _apiClient.get(
      'team/chat?limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load team chat messages.');
    }
    return TeamChatOverview.fromJson(data);
  }

  Future<TeamChatOverview> sendTeamChatMessage(
    AppSession session, {
    required String content,
  }) async {
    final data = await _apiClient.post(
      'team/chat/send',
      body: {'content': content},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to send the team chat message.');
    }
    return TeamChatOverview.fromJson(data);
  }

  Future<TeamChatOverview> markTeamChatRead(AppSession session) async {
    final data = await _apiClient.post(
      'team/chat/read',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to update team chat read state.');
    }
    return TeamChatOverview.fromJson(data);
  }

  Future<ChatReportResult> reportTeamChatMessage(
    AppSession session, {
    required int messageId,
    required String reason,
    String description = '',
  }) async {
    final data = await _apiClient.post(
      'team/chat/$messageId/report',
      body: {
        'reason': reason,
        'description': description,
      },
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to submit the chat report.');
    }
    return ChatReportResult.fromJson(data);
  }
}
