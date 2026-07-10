import 'package:innocence_flutter/core/network/api_client.dart';
import 'package:innocence_flutter/core/network/api_exception.dart';
import 'package:innocence_flutter/features/auth/domain/models/app_session.dart';
import 'package:innocence_flutter/features/friends/domain/models/friend_overview.dart';

class FriendApi {
  FriendApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<FriendOverview> getOverview(AppSession session) async {
    final data = await _apiClient.get(
      'friends/overview',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to load the friend overview.');
    }
    return FriendOverview.fromJson(data);
  }

  Future<List<FriendSearchItemModel>> search(
    AppSession session, {
    required String keyword,
  }) async {
    final encodedKeyword = Uri.encodeQueryComponent(keyword);
    final data = await _apiClient.get(
      'friends/search?keyword=$encodedKeyword',
      headers: session.authHeaders,
    );
    if (data is! List<dynamic>) {
      throw const ApiException('Failed to search for users.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(FriendSearchItemModel.fromJson)
        .toList();
  }

  Future<FriendOverview> createRequest(
    AppSession session, {
    required int targetUserId,
    String message = '',
  }) async {
    final data = await _apiClient.post(
      'friends/requests',
      body: {
        'targetUserId': targetUserId,
        'message': message,
      },
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to send the friend request.');
    }
    return FriendOverview.fromJson(data);
  }

  Future<FriendOverview> respondRequest(
    AppSession session, {
    required int requestId,
    required bool accept,
  }) async {
    final data = await _apiClient.post(
      'friends/requests/$requestId/respond',
      body: {'accept': accept},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to respond to the friend request.');
    }
    return FriendOverview.fromJson(data);
  }

  Future<FriendOverview> createGroup(
    AppSession session, {
    required String groupName,
  }) async {
    final data = await _apiClient.post(
      'friends/groups',
      body: {'groupName': groupName},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to create the friend group.');
    }
    return FriendOverview.fromJson(data);
  }

  Future<FriendOverview> moveToGroup(
    AppSession session, {
    required int friendUserId,
    required int groupId,
  }) async {
    final data = await _apiClient.put(
      'friends/$friendUserId/group',
      body: {'groupId': groupId},
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to move the friend.');
    }
    return FriendOverview.fromJson(data);
  }

  Future<FriendOverview> deleteFriend(
    AppSession session, {
    required int friendUserId,
  }) async {
    final data = await _apiClient.delete(
      'friends/$friendUserId',
      headers: session.authHeaders,
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Failed to delete the friend.');
    }
    return FriendOverview.fromJson(data);
  }
}
