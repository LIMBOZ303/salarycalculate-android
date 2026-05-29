class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  final String message;
  final int? statusCode;
  final String? error;

  @override
  String toString() => message;
}
