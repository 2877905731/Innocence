class ChatReportResult {
  const ChatReportResult({
    required this.reportId,
    required this.message,
  });

  final int reportId;
  final String message;

  factory ChatReportResult.fromJson(Map<String, dynamic> json) {
    return ChatReportResult(
      reportId: _toInt(json['reportId']),
      message: '${json['message'] ?? ''}',
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    return int.tryParse('$value') ?? fallback;
  }
}
