/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException(message: $message, code: $code)';
  }
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
    String message, {
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// AI Service related exceptions
class AIServiceException extends AppException {
  AIServiceException(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'AI_SERVICE_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Firebase/Database related exceptions
class DatabaseException extends AppException {
  DatabaseException(
    String message, {
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code ?? 'DATABASE_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Not Found exceptions
class NotFoundException extends AppException {
  NotFoundException(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'NOT_FOUND',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Permission related exceptions
class PermissionException extends AppException {
  PermissionException(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'PERMISSION_DENIED',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Rate limit exceeded exceptions
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  RateLimitException(
    String message, {
    this.retryAfterSeconds,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'RATE_LIMIT_EXCEEDED',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Server error exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    String message, {
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'SERVER_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Configuration error exceptions
class ConfigurationException extends AppException {
  ConfigurationException(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: 'CONFIGURATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
