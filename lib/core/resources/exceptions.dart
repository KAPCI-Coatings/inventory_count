class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([String message = 'Server Error Occurred']) : super(message);
}

class CacheException extends AppException {
  CacheException([String message = 'Cache Error Occurred']) : super(message);
}

class NetworkException extends AppException {
  NetworkException([String message = 'No Internet Connection']) : super(message);
}

class ValidationException extends AppException {
  ValidationException([String message = 'Validation Error']) : super(message);
}

class ExceptionHandler {
  static String handle(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
