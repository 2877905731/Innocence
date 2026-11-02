class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.statusCode,
    this.requestId,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? requestId;

  @override
  String toString() {
    return 'ApiException(code: $code, statusCode: $statusCode, message: $message)';
  }
}
