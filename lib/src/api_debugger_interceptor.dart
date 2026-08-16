import 'package:dio/dio.dart';

import 'api_debugger_controller.dart';
import 'api_log_record.dart';

class ApiDebuggerInterceptor extends Interceptor {
  ApiDebuggerInterceptor({ApiDebugger? debugger})
      : _debugger = debugger ?? ApiDebugger.instance;

  static const _startTimeKey = 'api_debugger.start_time';
  final ApiDebugger _debugger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (ApiDebugger.enabled) options.extra[_startTimeKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _debugger.capture(
      _record(
        response.requestOptions,
        statusCode: response.statusCode,
        responseBody: response.data,
      ),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _debugger.capture(
      _record(
        err.requestOptions,
        statusCode: err.response?.statusCode,
        responseBody: err.response?.data,
        error: err.message ?? err.toString(),
      ),
    );
    handler.next(err);
  }

  ApiLogRecord _record(
    RequestOptions request, {
    int? statusCode,
    dynamic responseBody,
    String? error,
  }) {
    final startedAt = request.extra[_startTimeKey];
    return ApiLogRecord(
      url: request.uri.toString(),
      method: request.method,
      headers: Map<String, dynamic>.from(request.headers),
      requestBody: request.data,
      queryParameters: Map<String, dynamic>.from(request.queryParameters),
      statusCode: statusCode,
      responseBody: responseBody,
      error: error,
      timestamp: DateTime.now(),
      duration:
          startedAt is DateTime ? DateTime.now().difference(startedAt) : null,
    );
  }
}
