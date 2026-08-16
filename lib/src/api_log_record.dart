class ApiLogRecord {
  const ApiLogRecord({
    required this.url,
    required this.method,
    required this.headers,
    required this.statusCode,
    required this.timestamp,
    this.requestBody,
    this.queryParameters,
    this.responseBody,
    this.error,
    this.duration,
  });

  final String url;
  final String method;
  final Map<String, dynamic> headers;
  final dynamic requestBody;
  final Map<String, dynamic>? queryParameters;
  final int? statusCode;
  final dynamic responseBody;
  final String? error;
  final DateTime timestamp;
  final Duration? duration;

  bool get isError =>
      error != null ||
      statusCode == null ||
      statusCode! < 200 ||
      statusCode! >= 300;

  Map<String, dynamic> toJson() => {
        'url': url,
        'method': method,
        'headers': headers,
        'requestBody': requestBody,
        'queryParameters': queryParameters,
        'statusCode': statusCode,
        'responseBody': responseBody,
        'error': error,
        'timestamp': timestamp.toIso8601String(),
        'durationMs': duration?.inMilliseconds,
      };
}
