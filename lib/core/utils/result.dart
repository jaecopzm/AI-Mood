/// A type that represents either success or failure
class Result<T> {
  final T? _data;
  final dynamic _error;
  final bool _isSuccess;

  const Result.success(T data)
      : _data = data,
        _error = null,
        _isSuccess = true;

  const Result.failure(dynamic error)
      : _data = null,
        _error = error,
        _isSuccess = false;

  /// Check if this result is a success
  bool get isSuccess => _isSuccess;

  /// Check if this result is a failure
  bool get isFailure => !_isSuccess;

  /// Get the data if success, otherwise null
  T? get data => _data;

  /// Get the error if failure, otherwise null
  dynamic get error => _error;

  /// Get data or throw error
  T get dataOrThrow {
    if (_isSuccess) {
      return _data as T;
    } else {
      throw _error;
    }
  }

  /// Get data or return a default value
  T getOrElse(T defaultValue) {
    return _isSuccess ? _data as T : defaultValue;
  }

  /// Transform the data if success
  Result<R> map<R>(R Function(T data) transform) {
    if (_isSuccess) {
      try {
        return Result.success(transform(_data as T));
      } catch (e) {
        return Result.failure(e);
      }
    }
    return Result.failure(_error);
  }

  /// Handle both success and failure cases
  R when<R>({
    required R Function(T data) success,
    required R Function(dynamic error) failure,
  }) {
    if (_isSuccess) {
      return success(_data as T);
    } else {
      return failure(_error);
    }
  }

  /// Handle both success and failure cases with async functions
  Future<R> whenAsync<R>({
    required Future<R> Function(T data) success,
    required Future<R> Function(dynamic error) failure,
  }) async {
    if (_isSuccess) {
      return await success(_data as T);
    } else {
      return await failure(_error);
    }
  }

  /// Execute a function only if success
  Result<T> onSuccess(void Function(T data) action) {
    if (_isSuccess) {
      action(_data as T);
    }
    return this;
  }

  /// Execute a function only if failure
  Result<T> onFailure(void Function(dynamic error) action) {
    if (isFailure) {
      action(_error);
    }
    return this;
  }

  @override
  String toString() {
    if (_isSuccess) {
      return 'Result.success($_data)';
    } else {
      return 'Result.failure($_error)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other._isSuccess == _isSuccess &&
        other._data == _data &&
        other._error == _error;
  }

  @override
  int get hashCode => Object.hash(_isSuccess, _data, _error);
}
