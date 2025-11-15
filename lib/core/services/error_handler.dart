import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:dio/dio.dart';
import '../exceptions/app_exceptions.dart';
import 'logger_service.dart';

/// Service for handling and transforming errors
class ErrorHandler {
  /// Get a user-friendly error message from any error
  static String getUserFriendlyMessage(dynamic error) {
    LoggerService.error('Error occurred', error);

    if (error is AppException) {
      return error.message;
    }

    if (error is NetworkException) {
      return 'Network error. Please check your internet connection.';
    }

    if (error is AuthException) {
      return error.message;
    }

    if (error is ValidationException) {
      return error.message;
    }

    if (error is AIServiceException) {
      return 'AI service is currently unavailable. Please try again later.';
    }

    if (error is DatabaseException) {
      return 'Database error occurred. Please try again.';
    }

    if (error is RateLimitException) {
      if (error.retryAfterSeconds != null) {
        return 'Rate limit exceeded. Please try again in ${error.retryAfterSeconds} seconds.';
      }
      return 'Too many requests. Please try again later.';
    }

    if (error is firebase_auth.FirebaseAuthException) {
      return _handleFirebaseAuthException(error);
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }

    if (error is TypeError) {
      return 'Data processing error. Please contact support.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle Firebase Authentication exceptions
  static String _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        return 'Authentication failed: ${error.message ?? "Unknown error"}';
    }
  }

  /// Handle Dio (HTTP) exceptions
  static String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          return _handleHttpStatusCode(statusCode);
        }
        return 'Server error occurred. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please check your connection.';
      case DioExceptionType.unknown:
        return 'Network error occurred. Please try again.';
    }
  }

  /// Handle HTTP status codes
  static String _handleHttpStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access forbidden. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Server error ($statusCode). Please try again.';
    }
  }

  /// Log error with context
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    String? userId,
  }) {
    final errorInfo = StringBuffer();
    errorInfo.writeln('=== Error Log ===');
    errorInfo.writeln('Error: $error');
    errorInfo.writeln('Type: ${error.runtimeType}');

    if (userId != null) {
      errorInfo.writeln('User ID: $userId');
    }

    if (context != null && context.isNotEmpty) {
      errorInfo.writeln('Context:');
      context.forEach((key, value) {
        errorInfo.writeln('  $key: $value');
      });
    }

    LoggerService.error(errorInfo.toString(), error, stackTrace);

    // TODO: Send to Firebase Crashlytics or Sentry in production
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: context);
  }

  /// Convert Firebase exception to AppException
  static AppException convertFirebaseException(
    firebase_auth.FirebaseAuthException error,
  ) {
    return AuthException(
      _handleFirebaseAuthException(error),
      code: error.code,
      originalError: error,
      stackTrace: error.stackTrace,
    );
  }

  /// Convert Dio exception to AppException
  static AppException convertDioException(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return NetworkException(
        _handleDioException(error),
        originalError: error,
        stackTrace: error.stackTrace,
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return ServerException(
        _handleDioException(error),
        statusCode: statusCode,
        originalError: error,
        stackTrace: error.stackTrace,
      );
    }

    return NetworkException(
      _handleDioException(error),
      originalError: error,
      stackTrace: error.stackTrace,
    );
  }
}
