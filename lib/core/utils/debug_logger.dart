import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_logger.g.dart';

enum LogLevel { info, warning, error, debug }

class LogEntry {
  final String message;
  final LogLevel level;
  final DateTime timestamp;

  LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
  });
}

@Riverpod(keepAlive: true)
class DebugLogger extends _$DebugLogger {
  @override
  List<LogEntry> build() => [];

  void addLog(String message, {LogLevel level = LogLevel.info}) {
    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
    );
    state = [...state, entry];
    // También imprimir en consola real para desarrollo con PC
    print('[${level.name.toUpperCase()}] $message');
  }

  void clear() {
    state = [];
  }
}
