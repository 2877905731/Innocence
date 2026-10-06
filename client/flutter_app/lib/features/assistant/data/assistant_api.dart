import 'dart:async';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/models/app_session.dart';

class AssistantApi {
  AssistantApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<Map<String, dynamic>> call(AppSession session, String path,
      {Map<String, dynamic>? body}) async {
    final result = await (body == null
            ? _client.get('assistant/$path', headers: session.authHeaders)
            : _client.post('assistant/$path',
                headers: session.authHeaders, body: body))
        .timeout(const Duration(seconds: 25));
    if (result is! Map<String, dynamic>) {
      throw const ApiException('助手返回格式无效 / Invalid assistant response.');
    }
    return result;
  }
}
