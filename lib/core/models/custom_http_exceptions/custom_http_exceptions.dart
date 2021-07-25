import '/core/constants/app_error_messages.dart';

abstract class CustomHttpException implements Exception {
  final String message;
  final String? responseBody;

  const CustomHttpException({
    required this.message,
    this.responseBody,
  });
}

class UnknownHttpException extends CustomHttpException{
  const UnknownHttpException({String? responseBody}) : super(message: AppErrorMessages.unknownRequestError, responseBody: responseBody);
}

/// 400 Bad Request
class BadRequestException extends CustomHttpException {
  const BadRequestException({
    String? responseBody,
  }) : super(message: 'Error: 400 Bad Request.', responseBody: responseBody);
}

/// 401 Unauthorized
class UnauthorizedException extends CustomHttpException{
  const UnauthorizedException({
    String? responseBody,
  }) : super(message: AppErrorMessages.unauthorizedError, responseBody: responseBody);
}

/// 403 Forbidden
class ForbiddenException extends CustomHttpException{
  const ForbiddenException({
    String? responseBody,
  }) : super(message: 'Error: 403 Forbidden.', responseBody: responseBody);
}

/// 404 Not Found
class NotFound404Exception extends CustomHttpException{
  const NotFound404Exception({
    String? responseBody,
  }) : super(message: 'Error: 404 Not Found.', responseBody: responseBody);
}

/// 408 Request Timeout
class RequestTimeoutException extends CustomHttpException{
  const RequestTimeoutException({
    String? responseBody,
  }) : super(message: 'Error: 408 Request Timeout.', responseBody: responseBody);
}

/// 415 Unsupported Media Type
class UnsupportedMediaTypeException extends CustomHttpException {
  const UnsupportedMediaTypeException({
    String? responseBody,
  }) : super(message: 'Error: 415 Unsupported Media Type.', responseBody: responseBody);
}

/// 429 Too Many Requests
class TooManyRequestsException extends CustomHttpException {
  const TooManyRequestsException({
    String? responseBody,
  }) : super(message: 'Error: 429 Too Many Requests.', responseBody: responseBody);
}

/// 444 No Response (Nginx), and all 5xx Errors
class ProblemWithServerException extends CustomHttpException{
  const ProblemWithServerException({
    String? responseBody,
  }) : super(message: AppErrorMessages.serverError, responseBody: responseBody);
}

