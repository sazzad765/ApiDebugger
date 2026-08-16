# api_debugger

A reusable, in-app Dio request inspector for Flutter. It adds a draggable bug
button, a request list, request details, copy-to-clipboard support, and a runtime
show/hide flag.

## Install

```yaml
dependencies:
  api_debugger:
    path: ../Debugger
```

## Initialize

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

The UI can be enabled or disabled anywhere. Disabling also clears captured logs.
Use the package widget to handle visibility and reactive rebuilding:

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

Router-based apps do not need a navigator key. Initialize the package and host
the debugger through the app builder:

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
