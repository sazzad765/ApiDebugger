# API Debugger

A modern in-app Dio network inspector for Flutter. Capture requests, responses,
errors, headers, bodies, query parameters, status codes, and timing without
leaving your app.

## Features

- Draggable network-inspector button with a request counter
- Request, response, and Dio error capture
- Headers, query parameters, bodies, status, timing, and timestamps
- Modern request list and detailed inspection view
- Copy complete request data to the clipboard
- Runtime enable/disable switch
- `MaterialApp` and `MaterialApp.router` support
- Configurable in-memory log limit

## Install

```yaml
dependencies:
  api_debugger: ^0.1.1
```

## Quick start

Initialize the debugger before `runApp`, add the switch anywhere in your app UI,
and attach the Dio interceptor to each client you want to inspect.

## Navigator-key setup

```dart
import 'package:api_debugger/api_debugger.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiDebugger.init(
    navigatorKey: navigatorKey,
  );
  runApp(const MyApp());
}

MaterialApp(
  navigatorKey: navigatorKey,
  // ...
);
```

Use the package switch to enable or disable capture at runtime. Disabling also
clears captured logs:

```dart
const ApiDebuggerSwitch()
```

`ApiDebuggerSwitch` is visible in debug builds. In release builds it is only
visible when built with `--dart-define=SHOW_DEBUGGER=true`.

## Capture Dio traffic

```dart
final dio = Dio();
dio.interceptors.add(ApiDebuggerInterceptor());
```

Add the interceptor to every Dio instance that should appear in the debugger.
The package captures URL, method, headers, query parameters, request body,
response/error body, status code, timestamp, and duration. Keep it after any
interceptor that adds authentication headers if those final headers should be
visible.

## Using `MaterialApp.router`

Router-based apps do not need a navigator key. Initialize the package without
one and host the debugger through the app builder:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiDebugger.init();
  runApp(const MyApp());
}

final appRouter = AppRouter();

MaterialApp.router(
  routerConfig: appRouter.config(),
  builder: (context, child) => ApiDebuggerOverlay(
    child: child ?? const SizedBox.shrink(),
  ),
);
```

The same `ApiDebugger.setEnabled(...)` and `ApiDebuggerInterceptor()` APIs work
with both navigation styles. Do not supply a navigator key when using
`ApiDebuggerOverlay`, otherwise two floating buttons can be created.

## Configuration

The nullable `enabled` argument controls whether the debugger is available.
When omitted or `null`, availability follows `kDebugMode || SHOW_DEBUGGER`.
By default, the runtime debugger starts off and `ApiDebuggerSwitch` controls it
by calling `ApiDebugger.setEnabled(value)`:

```dart
ApiDebugger.init();               // Available in debug/SHOW_DEBUGGER builds.
ApiDebugger.init(enabled: false); // Unavailable; switch is hidden.
ApiDebugger.init(enabled: true);  // Available; starts switched off.
```

To start capturing immediately and show the floating debugger as soon as the
app starts, enable both availability and the initial runtime state:

```dart
ApiDebugger.init(
  enabled: true,
  initShowDebugger: true,
);
```

`initShowDebugger` has no effect when `enabled` resolves to `false`.

Limit the number of records kept in memory with `maxLogs`:

```dart
ApiDebugger.init(maxLogs: 100);
```

Clear captured records manually when needed:

```dart
ApiDebugger.clear();
```

## Release builds

The debugger is unavailable by default in release builds. Opt in with a Dart
define:

```bash
flutter build apk --release --dart-define=SHOW_DEBUGGER=true
```

You remain responsible for ensuring sensitive headers and payloads are not
exposed in production builds.

## License

MIT
