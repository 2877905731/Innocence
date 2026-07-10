import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';

class AdminReportApi {
  AdminReportApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AdminReportListItem>> getReports(
    AppSession session, {
    String status = 'pending',
    String reportType = 'team_chat',
    int limit = 50,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/reports?status=$status&reportType=$reportType&limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load report list.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminReportListItem.fromJson)
        .toList();
  }

  Future<AdminReportDetail> getReportDetail(
    AppSession session, {
    required int reportId,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/reports/$reportId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load report detail.');
    }
    return AdminReportDetail.fromJson(data);
  }

  Future<AdminReportReviewResult> reviewReport(
    AppSession session, {
    required int reportId,
    required String decision,
    required bool deleteContent,
    required String punishmentType,
    required int durationDays,
    required String reason,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/reports/$reportId/review',
      headers: session.authHeaders,
      body: {
        'decision': decision,
        'deleteContent': deleteContent,
        'punishmentType': punishmentType,
        'durationDays': durationDays,
        'reason': reason,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to submit report review.');
    }
    return AdminReportReviewResult.fromJson(data);
  }

  Future<List<AdminUserSearchItem>> searchUsers(
    AppSession session, {
    String keyword = '',
    int limit = 50,
  }) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final data = await _apiClient.get(
      '/api/admin/v1/users/search?keyword=$encodedKeyword&limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load user search results.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminUserSearchItem.fromJson)
        .toList();
  }

  Future<AdminUserDetail> getUserDetail(
    AppSession session, {
    required int userId,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/users/$userId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load user detail.');
    }
    return AdminUserDetail.fromJson(data);
  }

  Future<List<AdminUserReportItem>> getUserReports(
    AppSession session, {
    required int userId,
    int limit = 50,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/users/$userId/reports?limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load user report history.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminUserReportItem.fromJson)
        .toList();
  }

  Future<List<AdminUserPunishmentItem>> getUserPunishments(
    AppSession session, {
    required int userId,
    String status = 'active',
    int limit = 50,
  }) async {
    final encodedStatus = Uri.encodeQueryComponent(status);
    final data = await _apiClient.get(
      '/api/admin/v1/users/$userId/punishments?status=$encodedStatus&limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load user punishment history.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminUserPunishmentItem.fromJson)
        .toList();
  }

  Future<AdminLiftPunishmentResult> liftPunishment(
    AppSession session, {
    required int userId,
    required int punishmentId,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/users/$userId/punishments/$punishmentId/lift',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to lift the punishment.');
    }
    return AdminLiftPunishmentResult.fromJson(data);
  }

  Future<List<AdminTeamListItem>> getTeams(
    AppSession session, {
    String keyword = '',
    int? status,
    int limit = 50,
  }) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final statusPart = status == null ? '' : '&status=$status';
    final data = await _apiClient.get(
      '/api/admin/v1/teams?keyword=$encodedKeyword$statusPart&limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load team list.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminTeamListItem.fromJson)
        .toList();
  }

  Future<AdminTeamDetail> getTeamDetail(
    AppSession session, {
    required int teamId,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/teams/$teamId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load team detail.');
    }
    return AdminTeamDetail.fromJson(data);
  }

  Future<AdminTeamActionResult> removeTeamMember(
    AppSession session, {
    required int teamId,
    required int memberUserId,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/teams/$teamId/remove-member?memberUserId=$memberUserId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to remove the team member.');
    }
    return AdminTeamActionResult.fromJson(data);
  }

  Future<AdminTeamActionResult> dissolveTeam(
    AppSession session, {
    required int teamId,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/teams/$teamId/dissolve',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to dissolve the team.');
    }
    return AdminTeamActionResult.fromJson(data);
  }

  Future<List<AdminAnnouncementItem>> getAnnouncements(
    AppSession session, {
    int limit = 50,
  }) async {
    final data = await _apiClient.get(
      '/api/admin/v1/announcements?limit=$limit',
      headers: session.authHeaders,
    );
    if (data is! List) {
      throw const ApiException('Failed to load announcements.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(AdminAnnouncementItem.fromJson)
        .toList();
  }

  Future<AdminAnnouncementActionResult> createAnnouncement(
    AppSession session, {
    required String title,
    required String content,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/announcements',
      headers: session.authHeaders,
      body: {
        'title': title,
        'content': content,
      },
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to create the announcement.');
    }
    return AdminAnnouncementActionResult.fromJson(data);
  }

  Future<AdminAnnouncementActionResult> deleteAnnouncement(
    AppSession session, {
    required int announcementId,
  }) async {
    final data = await _apiClient.post(
      '/api/admin/v1/announcements/$announcementId/delete',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to delete the announcement.');
    }
    return AdminAnnouncementActionResult.fromJson(data);
  }
}
