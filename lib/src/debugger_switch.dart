import 'package:flutter/material.dart';

import 'api_debugger_controller.dart';

/// A reactive switch for enabling or disabling the API debugger.
///
/// The switch is hidden in release builds unless the app is built with
/// `--dart-define=SHOW_DEBUGGER=true`.
class ApiDebuggerSwitch extends StatelessWidget {
  const ApiDebuggerSwitch({
    super.key,
    this.activeColor,
    this.onChanged,
  });

  final Color? activeColor;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ApiDebugger.instance,
      builder: (context, child) {
        if (!ApiDebugger.available) return const SizedBox.shrink();
        return Switch(
          value: ApiDebugger.enabled,
          activeThumbColor: activeColor,
          activeTrackColor:
              (activeColor ?? const Color(0xFF6366F1)).withValues(alpha: .45),
          inactiveThumbColor: Theme.of(context).colorScheme.outline,
          inactiveTrackColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          trackOutlineColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? Colors.transparent
                : Theme.of(context).colorScheme.outlineVariant,
          ),
          thumbIcon: WidgetStateProperty.resolveWith(
            (states) => Icon(
              states.contains(WidgetState.selected)
                  ? Icons.wifi_tethering_rounded
                  : Icons.wifi_tethering_off_rounded,
              size: 16,
              color: states.contains(WidgetState.selected)
                  ? Colors.white
                  : Theme.of(context).colorScheme.surface,
            ),
          ),
          onChanged: (value) {
            ApiDebugger.setEnabled(value);
            onChanged?.call(value);
          },
        );
      },
    );
  }
}
