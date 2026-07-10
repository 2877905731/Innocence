import 'package:innocence_flutter/features/checkin/domain/models/check_in_status.dart';

class CheckInSubmitResult {
  const CheckInSubmitResult({
    required this.success,
    required this.message,
    required this.status,
  });

  final bool success;
  final String message;
  final CheckInStatus status;

  factory CheckInSubmitResult.fromJson(Map<String, dynamic> json) {
    return CheckInSubmitResult(
      success: json['success'] == true || json['success'] == 1,
      message: '${json['message'] ?? ''}',
      status: CheckInStatus.fromJson(
        json['status'] is Map<String, dynamic>
            ? json['status'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
    );
  }
}
