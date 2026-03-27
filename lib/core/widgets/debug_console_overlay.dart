import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:bazas/core/theme/app_theme.dart';
import 'package:bazas/core/utils/debug_logger.dart';

class DebugConsoleOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const DebugConsoleOverlay({super.key, required this.child});

  @override
  ConsumerState<DebugConsoleOverlay> createState() => _DebugConsoleOverlayState();
}

class _DebugConsoleOverlayState extends ConsumerState<DebugConsoleOverlay> {
  bool _isVisible = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggle() => setState(() => _isVisible = !_isVisible);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isVisible)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.9),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(child: _buildLogList()),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 120,
          right: 0,
          child: GestureDetector(
            onLongPress: _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withOpacity(0.15),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                border: Border.all(color: AppColors.neonCyan.withOpacity(0.3), width: 1),
              ),
              child: const Icon(Icons.bug_report, color: AppColors.neonCyan, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.backgroundDark,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('CONSOLE DEBUG', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                onPressed: () => ref.read(debugLoggerProvider.notifier).clear(),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: _toggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    final logs = ref.watch(debugLoggerProvider);

    if (logs.isEmpty) {
      return const Center(child: Text('No hay logs todavía.', style: TextStyle(color: Colors.white24)));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final time = DateFormat('HH:mm:ss').format(log.timestamp);
        
        Color color = Colors.white70;
        if (log.level == LogLevel.error) color = AppColors.error;
        if (log.level == LogLevel.warning) color = AppColors.neonOrange;
        if (log.level == LogLevel.debug) color = AppColors.neonCyan;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              children: [
                TextSpan(text: '[$time] ', style: const TextStyle(color: Colors.white30)),
                TextSpan(text: log.message, style: TextStyle(color: color)),
              ],
            ),
          ),
        );
      },
    );
  }
}
