class AppException implements Exception {
  final String message;
  final String? code;
  

  AppException(this.message, {this.code});
  

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException([super.message = 'Server Error Occurred']);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache Error Occurred']);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No Internet Connection']);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Validation Error']);
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
