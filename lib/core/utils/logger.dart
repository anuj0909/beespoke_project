import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static const String _tag = 'StyleSwipe';

  static void d(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void i(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void w(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message, tag: tag);
    if (error != null) {
      _log(LogLevel.error, '  Error: $error', tag: tag);
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('$_prefix(stacktrace) $stackTrace');
    }
  }

  static void _log(LogLevel level, String message, {String? tag}) {
    if (!kDebugMode) return;
    final prefix = _levelPrefix(level);
    final label = tag ?? _tag;
    debugPrint('$prefix [$label] $message');
  }

  static String get _prefix => '📱';

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍 DEBUG';
      case LogLevel.info:
        return 'ℹ️  INFO';
      case LogLevel.warning:
        return '⚠️  WARN';
      case LogLevel.error:
        return '❌ ERROR';
    }
  }
}