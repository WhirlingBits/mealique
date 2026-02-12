/// Base class for all API-related exceptions.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    String result = "API Error";
    if (statusCode != null) {
      result += " (Code $statusCode)";
    }
    return "$result: $message";
  }
}

/// Exception for network-related issues (e.g., no connection, timeouts).
class NetworkException extends ApiException {
  NetworkException(String message) : super(message: "Network Error: $message");
}

/// Exception for unauthorized access (401).
class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = "Unauthorized"})
      : super(message: message, statusCode: 401);
}

/// Exception for server-side errors (5xx).
class ServerException extends ApiException {
  ServerException({String message = "Server Error", int? statusCode})
      : super(message: message, statusCode: statusCode);
}

/// Exception for not found errors (404).
class NotFoundException extends ApiException {
  NotFoundException({String message = "Not Found"})
      : super(message: message, statusCode: 404);
}

/// General-purpose exception for other client-side errors (4xx).
class BadRequestException extends ApiException {
  BadRequestException({String message = "Bad Request", int? statusCode})
      : super(message: message, statusCode: statusCode);
}
