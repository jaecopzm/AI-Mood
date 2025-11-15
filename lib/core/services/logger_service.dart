import 'package:logger/logger.dart';

/// Centralized logging service
class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug,
  );

  /// Log debug information
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.d(message, error: error);
    } else {
      _logger.d(message);
    }
  }

  /// Log general information
  static void info(String message) {
    _logger.i(message);
  }

  /// Log warnings
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.w(message, error: error);
    } else {
      _logger.w(message);
    }
  }

  /// Log errors
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.e(message, error: error);
    } else {
      _logger.e(message);
    }
  }

  /// Log fatal errors
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.f(message, error: error);
    } else {
      _logger.f(message);
    }
  }

  /// Log trace information
  static void trace(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null && stackTrace != null) {
      _logger.t(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger.t(message, error: error);
    } else {
      _logger.t(message);
    }
  }
}
