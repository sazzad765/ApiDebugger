import 'package:api_debugger/api_debugger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns child directly when debugger is unavailable',
      (tester) async {
    ApiDebugger.init(enabled: false);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ApiDebuggerOverlay(child: Text('App child')),
      ),
    );

    expect(find.text('App child'), findsOneWidget);
    expect(find.byType(Overlay), findsNothing);
  });

  testWidgets(
      'opens above MaterialApp.router-style builder without Navigator context',
      (tester) async {
    ApiDebugger.init(enabled: true);
    ApiDebugger.setEnabled(true);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => ApiDebuggerOverlay(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(body: Text('App')),
      ),
    );

    await tester.tap(find.byIcon(Icons.travel_explore_rounded));
    await tester.pump();

    expect(find.text('Network Inspector'), findsOneWidget);
    expect(tester.takeException(), isNull);

    ApiDebugger.setEnabled(false);
  });
}
