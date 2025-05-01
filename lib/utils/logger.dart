import 'dart:developer' as developer;

/// App-specific logger that helps filter out unnecessary logs
class AppLogger {
  static const String _appName = 'MenciMeter';
  
  /// Log informational message
  static void log(String message, {String? name, Object? error}) {
    developer.log(
      message,
      name: name ?? _appName,
      error: error,
    );
  }
  
  /// Log error message with optional stack trace
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      'ERROR: $message',
      name: _appName,
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Log warning message
  static void warning(String message, {Object? error}) {
    developer.log(
      'WARNING: $message',
      name: _appName,
      error: error,
    );
  }
  
  /// Log debug message (only in debug builds)
  static void debug(String message, {String? category}) {
    // In a real app, you might want to check if in debug mode
    // and skip this in production builds
    developer.log(
      'DEBUG: $message',
      name: category ?? _appName,
    );
  }
} 