import 'package:dio/dio.dart';
import '../services/logger_service.dart';

/// Dio HTTP client with interceptors and configuration
class DioClient {
  late final Dio _dio;

  DioClient({
    String? baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_RetryInterceptor());
  }

  /// Get the underlying Dio instance
  Dio get dio => _dio;

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    LoggerService.debug(
      'HTTP Request: ${options.method} ${options.uri}',
    );
    LoggerService.trace('Headers: ${options.headers}');
    if (options.data != null) {
      LoggerService.trace('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerService.debug(
      'HTTP Response: ${response.statusCode} ${response.requestOptions.uri}',
    );
    LoggerService.trace('Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerService.error(
      'HTTP Error: ${err.response?.statusCode} ${err.requestOptions.uri}',
      err,
      err.stackTrace,
    );
    super.onError(err, handler);
  }
}

/// Retry interceptor for network failures
class _RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        LoggerService.warning(
          'Retrying request (${retryCount + 1}/$maxRetries): ${err.requestOptions.uri}',
        );

        // Wait before retrying
        await Future.delayed(retryDelay * (retryCount + 1));

        // Update retry count
        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          // Retry the request
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}
