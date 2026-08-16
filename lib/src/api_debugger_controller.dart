import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'api_log_record.dart';
import 'debugger_widgets.dart';

/// Global controller for the in-app API debugger.
///
/// Call [init] before `runApp` and attach `ApiDebuggerInterceptor()` to each
/// Dio instance you want to inspect. A navigator key is optional when using
/// `ApiDebuggerOverlay` with `MaterialApp.builder`.
class ApiDebugger extends ChangeNotifier {
  ApiDebugger._();

  static final ApiDebugger instance = ApiDebugger._();

  final List<ApiLogRecord> _logs = [];
  GlobalKey<NavigatorState>? _navigatorKey;
  OverlayEntry? _buttonOverlay;
  OverlayEntry? _logsOverlay;
  bool _enabled = false;
  bool _available = false;
  int _maxLogs = 200;

  static void init({
    GlobalKey<NavigatorState>? navigatorKey,
    bool? enabled,
    bool initShowDebugger = false,
    int maxLogs = 200,
  }) {
    assert(maxLogs > 0);
    const showInRelease = bool.fromEnvironment('SHOW_DEBUGGER');
    final resolvedAvailability = enabled ?? (kDebugMode || showInRelease);
    instance._navigatorKey = navigatorKey;
    instance._maxLogs = maxLogs;
    instance._available = resolvedAvailability;
    instance._enabled = resolvedAvailability && initShowDebugger;
    instance._removeOverlays();
    instance._logs.clear();
    instance.notifyListeners();
    if (instance._enabled && navigatorKey != null) {
      instance._scheduleButton();
    }
  }

  static bool get available => instance._available;
  static bool get enabled => instance._enabled;
  static List<ApiLogRecord> get logs => List.unmodifiable(instance._logs);

  static void setEnabled(bool value) => instance._setEnabled(value);
  static void toggle() => setEnabled(!enabled);
  static void clear() => instance._clear();

  void capture(ApiLogRecord record) {
    if (!_enabled) return;
    _logs.insert(0, record);
    if (_logs.length > _maxLogs) _logs.removeRange(_maxLogs, _logs.length);
    notifyListeners();
    if (_navigatorKey != null) _scheduleButton();
  }

  void _setEnabled(bool value) {
    value = _available && value;
    if (_enabled == value) return;
    _enabled = value;
    if (value) {
      if (_navigatorKey != null) _scheduleButton();
    } else {
      _removeOverlays();
      _logs.clear();
    }
    notifyListeners();
  }

  void _clear() {
    _logs.clear();
    notifyListeners();
  }

  void _scheduleButton() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _showButton());
  }

  void _showButton() {
    if (!_enabled || _buttonOverlay?.mounted == true) return;
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;
    _buttonOverlay = OverlayEntry(
      builder: (_) =>
          DebuggerFloatingButton(controller: this, onPressed: _toggleLogs),
    );
    overlay.insert(_buttonOverlay!);
  }

  void _toggleLogs() {
    if (_logsOverlay?.mounted == true) {
      _hideLogs();
      return;
    }
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;
    _logsOverlay = OverlayEntry(
      builder: (_) => DebuggerLogPanel(
        controller: this,
        onClose: _hideLogs,
        onSelect: _showDetails,
      ),
    );
    overlay.insert(_logsOverlay!);
  }

  void _showDetails(ApiLogRecord record) {
    _hideLogs();
    final context = _navigatorKey?.currentContext;
    if (context == null) return;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => DebuggerDetailsDialog(record: record),
    );
  }

  void _hideLogs() {
    _logsOverlay?.remove();
    _logsOverlay = null;
  }

  void _removeOverlays() {
    _hideLogs();
    _buttonOverlay?.remove();
    _buttonOverlay = null;
  }
}
