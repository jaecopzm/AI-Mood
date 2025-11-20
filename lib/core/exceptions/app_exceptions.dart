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
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'NETWORK_ERROR',
        );
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'AUTH_ERROR',
        );
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
    super.message, {
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'VALIDATION_ERROR',
        );
}

/// AI Service related exceptions
class AIServiceException extends AppException {
  AIServiceException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'AI_SERVICE_ERROR',
        );
}

/// Firebase/Database related exceptions
class DatabaseException extends AppException {
  DatabaseException(
    super.message, {
    String? code,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: code ?? 'DATABASE_ERROR',
        );
}

/// Not Found exceptions
class NotFoundException extends AppException {
  NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'NOT_FOUND',
        );
}

/// Permission related exceptions
class PermissionException extends AppException {
  PermissionException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'PERMISSION_DENIED',
        );
}

/// Rate limit exceeded exceptions
class RateLimitException extends AppException {
  final int? retryAfterSeconds;

  RateLimitException(
    super.message, {
    this.retryAfterSeconds,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'RATE_LIMIT_EXCEEDED',
        );
}

/// Server error exceptions
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    super.message, {
    this.statusCode,
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'SERVER_ERROR',
        );
}

/// Configuration error exceptions
class ConfigurationException extends AppException {
  ConfigurationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'CONFIGURATION_ERROR',
        );
}
