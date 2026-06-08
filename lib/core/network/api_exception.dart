class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.error,
    this.responseData,
  });

  final String message;
  final int? statusCode;
  final String? error;
  final Map<String, dynamic>? responseData;

  @override
  String toString() => message;
}
