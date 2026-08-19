import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_debugger_controller.dart';
import 'api_log_record.dart';

class DebuggerFloatingButton extends StatefulWidget {
  const DebuggerFloatingButton({
    super.key,
    required this.controller,
    required this.onPressed,
  });

  final ApiDebugger controller;
  final VoidCallback onPressed;

  @override
  State<DebuggerFloatingButton> createState() => _DebuggerFloatingButtonState();
}

class _DebuggerFloatingButtonState extends State<DebuggerFloatingButton> {
  Offset _position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) => Positioned(
        left: _position.dx,
        top: _position.dy,
        child: GestureDetector(
          onPanUpdate: (details) {
            final screen = MediaQuery.sizeOf(context);
            setState(() {
              _position = Offset(
                (_position.dx + details.delta.dx).clamp(0.0, screen.width - 56),
                (_position.dy + details.delta.dy)
                    .clamp(0.0, screen.height - 56),
              );
            });
          },
          child: _button(),
        ),
      );

  Widget _button() => AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x554F46E5),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.travel_explore_rounded,
                    color: Colors.white,
                    size: 27,
                  ),
                  if (ApiDebugger.logs.isNotEmpty)
                    Positioned(
                      right: -1,
                      top: -1,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Color(0xFFEF4444),
                        child: Text(
                          ApiDebugger.logs.length > 99
                              ? '99+'
                              : '${ApiDebugger.logs.length}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}

class DebuggerLogPanel extends StatelessWidget {
  const DebuggerLogPanel({
    super.key,
    required this.controller,
    required this.onClose,
    required this.onSelect,
  });

  final ApiDebugger controller;
  final VoidCallback onClose;
  final ValueChanged<ApiLogRecord> onSelect;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withValues(alpha: .58),
        child: SafeArea(
          child: Center(
            child: Container(
              width: MediaQuery.sizeOf(context).width * .96,
              height: MediaQuery.sizeOf(context).height * .85,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 40,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.monitor_heart_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Network Inspector',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -.2,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: controller,
                                builder: (_, __) => Text(
                                  '${ApiDebugger.logs.length} captured requests',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: 'Clear',
                          onPressed: ApiDebugger.clear,
                          icon: const Icon(Icons.delete_sweep_outlined),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          tooltip: 'Close',
                          onPressed: onClose,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: _neutralBorder(context),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (_, __) {
                        final logs = ApiDebugger.logs;
                        if (logs.isEmpty) {
                          return const _EmptyLogState();
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                          itemCount: logs.length,
                          itemBuilder: (_, index) {
                            final log = logs[index];
                            return _RequestLogCard(
                              record: log,
                              onTap: () => onSelect(log),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _EmptyLogState extends StatelessWidget {
  const _EmptyLogState();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sync_alt_rounded,
                  size: 32,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Waiting for API traffic',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Requests will appear here as your app communicates with its services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.4,
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
}

class _RequestLogCard extends StatelessWidget {
  const _RequestLogCard({required this.record, required this.onTap});

  final ApiLogRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor =
        record.isError ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final uri = Uri.tryParse(record.url);
    final host = uri?.host.isNotEmpty == true ? uri!.host : 'Request';
    final path = uri == null
        ? record.url
        : '${uri.path.isEmpty ? '/' : uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _neutralBorder(context)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _LogChip(
                      label: record.method,
                      foreground: const Color(0xFF4F46E5),
                      background: const Color(0xFF6366F1),
                    ),
                    const Spacer(),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      record.statusCode?.toString() ?? 'ERROR',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(record.duration),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(record.timestamp),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.hour)}:${two(value.minute)}:${two(value.second)}';
  }
}

class _LogChip extends StatelessWidget {
  const _LogChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 80),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: background.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
      );
}

Color _neutralBorder(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF4B5563)
      : const Color(0xFFD1D5DB);
}

class DebuggerDetailsDialog extends StatelessWidget {
  const DebuggerDetailsDialog({
    super.key,
    required this.record,
    this.onClose,
  });

  final ApiLogRecord record;
  final VoidCallback? onClose;

  Color _statusColor() {
    if (record.isError) return const Color(0xFFEF4444);
    return const Color(0xFF10B981);
  }

  String _statusLabel() {
    if (record.statusCode == null) return 'ERROR';
    return record.statusCode.toString();
  }

  String _pretty(dynamic value) {
    if (value == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor();
    final uri = Uri.tryParse(record.url);
    final title = uri?.host.isNotEmpty == true ? uri!.host : 'Request details';
    final path = uri == null
        ? record.url
        : '${uri.path.isEmpty ? '/' : uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 14),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: .7),
                border: Border(
                  bottom: BorderSide(color: _neutralBorder(context)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      record.isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'API request details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          path,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose ?? () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  _metric(
                    context,
                    icon: Icons.http_rounded,
                    label: 'Method',
                    value: record.method,
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    icon: Icons.tag_rounded,
                    label: 'Status',
                    value: _statusLabel(),
                    valueColor: statusColor,
                  ),
                  const SizedBox(width: 8),
                  _metric(
                    context,
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(record.duration),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section(context, 'URL', record.url),
                      _section(context, 'Headers', _pretty(record.headers)),
                      _section(
                        context,
                        'Query parameters',
                        _pretty(record.queryParameters),
                      ),
                      _section(
                        context,
                        'Request body',
                        _pretty(record.requestBody),
                      ),
                      _section(
                        context,
                        'Response body',
                        _pretty(record.responseBody),
                      ),
                      if (record.error != null)
                        _section(context, 'Error', record.error!),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  top: BorderSide(color: _neutralBorder(context)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: _pretty(record.toJson())),
                      );
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy all'),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.tonal(
                    onPressed: onClose ?? () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          border: Border.all(color: _neutralBorder(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: colors.onSurfaceVariant),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String value) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          border: Border.all(color: _neutralBorder(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Divider(height: 1, color: _neutralBorder(context)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: colors.surfaceContainerLow.withValues(alpha: .55),
              child: SelectableText(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.35,
                  color: colors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration? duration) {
  if (duration == null) return '-';

  final milliseconds = duration.inMilliseconds;
  if (milliseconds < 1000) return '${milliseconds}ms';

  final seconds = milliseconds ~/ 1000;
  final remainingMilliseconds = milliseconds.remainder(1000);
  if (remainingMilliseconds == 0) return '${seconds}s';

  return '${seconds}s ${remainingMilliseconds}ms';
}
