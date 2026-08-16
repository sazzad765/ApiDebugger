import 'package:api_debugger/api_debugger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('marks successful and failed records correctly', () {
    final success = ApiLogRecord(
      url: 'https://example.com/users',
      method: 'GET',
      headers: const {},
      statusCode: 200,
      timestamp: DateTime(2026),
    );
    final failure = ApiLogRecord(
      url: 'https://example.com/users',
      method: 'GET',
      headers: const {},
      statusCode: 500,
      timestamp: DateTime(2026),
    );

    expect(success.isError, isFalse);
    expect(failure.isError, isTrue);
  });

  test('serializes captured data', () {
    final record = ApiLogRecord(
      url: 'https://example.com',
      method: 'POST',
      headers: const {'content-type': 'application/json'},
      requestBody: const {'name': 'Codex'},
      statusCode: 201,
      responseBody: const {'id': 1},
      timestamp: DateTime.utc(2026, 1, 1),
      duration: const Duration(milliseconds: 42),
    );

    expect(record.toJson()['durationMs'], 42);
    expect(record.toJson()['statusCode'], 201);
  });
}
