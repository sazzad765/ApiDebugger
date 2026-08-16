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
              width: MediaQuery.sizeOf(context).width * .94,
              height: MediaQuery.sizeOf(context).height * .86,
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
                      '${record.duration?.inMilliseconds ?? '-'} ms',
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

  String _pretty(dynamic value) {
    if (value == null) return 'null';
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('API request details'),
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * .85,
          child: SingleChildScrollView(
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('URL', record.url),
                  _section(
                    'Method / status',
                    '${record.method} / ${record.statusCode ?? 'ERR'}',
                  ),
                  _section(
                    'Duration',
                    '${record.duration?.inMilliseconds ?? '-'} ms',
                  ),
                  _section('Headers', _pretty(record.headers)),
                  _section('Query', _pretty(record.queryParameters)),
                  _section('Request body', _pretty(record.requestBody)),
                  _section('Response body', _pretty(record.responseBody)),
                  if (record.error != null) _section('Error', record.error!),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _pretty(record.toJson())));
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy all'),
          ),
          TextButton(
            onPressed: onClose ?? () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );

  Widget _section(String title, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      );
}
