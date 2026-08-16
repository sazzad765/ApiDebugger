import 'package:api_debugger/api_debugger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial show flag enables capture only when available', () {
    ApiDebugger.init(enabled: true, initShowDebugger: true);
    expect(ApiDebugger.available, isTrue);
    expect(ApiDebugger.enabled, isTrue);

    ApiDebugger.init(enabled: false, initShowDebugger: true);
    expect(ApiDebugger.available, isFalse);
    expect(ApiDebugger.enabled, isFalse);
  });

  testWidgets('switch reacts to debugger enabled state', (tester) async {
    ApiDebugger.init(enabled: true);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ApiDebuggerSwitch())),
    );

    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(ApiDebugger.enabled, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    ApiDebugger.setEnabled(false);
  });

  testWidgets('switch is hidden when debugger is unavailable', (tester) async {
    ApiDebugger.init(enabled: false);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ApiDebuggerSwitch())),
    );

    expect(ApiDebugger.available, isFalse);
    expect(ApiDebugger.enabled, isFalse);
    expect(find.byType(Switch), findsNothing);

    ApiDebugger.setEnabled(true);
    expect(ApiDebugger.enabled, isFalse);
  });
}
