import 'package:flutter/material.dart';

import 'api_debugger_controller.dart';
import 'api_log_record.dart';
import 'debugger_widgets.dart';

/// Router-friendly debugger host for `MaterialApp.builder` and
/// `MaterialApp.router.builder`.
class ApiDebuggerOverlay extends StatefulWidget {
  const ApiDebuggerOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<ApiDebuggerOverlay> createState() => _ApiDebuggerOverlayState();
}

class _ApiDebuggerOverlayState extends State<ApiDebuggerOverlay> {
  bool _logsVisible = false;
  ApiLogRecord? _selectedRecord;
  late final OverlayEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = OverlayEntry(builder: (_) => _buildSurface());
  }

  @override
  void didUpdateWidget(ApiDebuggerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  void _showLogs() {
    _selectedRecord = null;
    _logsVisible = true;
    _entry.markNeedsBuild();
  }

  void _showDetails(ApiLogRecord record) {
    _logsVisible = false;
    _selectedRecord = record;
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    if (!ApiDebugger.available) return widget.child;
    return Overlay(initialEntries: [_entry]);
  }

  Widget _buildSurface() => AnimatedBuilder(
        animation: ApiDebugger.instance,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (ApiDebugger.enabled)
              DebuggerFloatingButton(
                controller: ApiDebugger.instance,
                onPressed: _showLogs,
              ),
            if (_logsVisible)
              DebuggerLogPanel(
                controller: ApiDebugger.instance,
                onClose: () {
                  _logsVisible = false;
                  _entry.markNeedsBuild();
                },
                onSelect: _showDetails,
              ),
            if (_selectedRecord case final record?)
              Positioned.fill(
                child: Material(
                  color: Colors.black54,
                  child: Center(
                    child: DebuggerDetailsDialog(
                      record: record,
                      onClose: () {
                        _selectedRecord = null;
                        _entry.markNeedsBuild();
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
