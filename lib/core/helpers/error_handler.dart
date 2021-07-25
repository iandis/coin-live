import 'dart:async' show TimeoutException;
import 'dart:developer' as dev show log;
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' as foundation show kDebugMode;

import '/core/constants/app_error_messages.dart';
import '/core/models/custom_http_exceptions/custom_http_exceptions.dart';
import '/core/models/websocket_models/response_models/ws_rejected_exception.dart';

class ErrorHandler {
  static void catchIt({
    required Object error,
    required void Function(String errorMessage) onCatch,
    StackTrace? stackTrace,
    String? customUnknownErrorMessage,
  }) {
    if(foundation.kDebugMode){
      dev.log('[ErrorHandler] caught an error caused by the following: ', stackTrace: stackTrace);
    }
    if (error is TimeoutException) {
      onCatch(AppErrorMessages.timeOutError);
    } else if (error is SocketException) {
      onCatch(AppErrorMessages.socketError);
    } else if (error is CustomHttpException) {
      onCatch(error.message);
      if(foundation.kDebugMode){
        dev.log('[${error.runtimeType}] Response body: \n${error.responseBody}');
      }
    } else if (error is WSRejectedException) {
      onCatch(error.message);
      if (foundation.kDebugMode) {
        dev.log('[Rejected] Message: \n${error.message}');
      }
    } else {
      onCatch(customUnknownErrorMessage ?? AppErrorMessages.unknownError);
    }
  }

  static CustomHttpException transformStatusCodeToException({
    required int statusCode,
    String? responseBody,
  }) {
    switch (statusCode) {
      case 400:
        return BadRequestException(responseBody: responseBody);
      case 401:
        return UnauthorizedException(responseBody: responseBody);
      case 403:
        return ForbiddenException(responseBody: responseBody);
      case 404:
        return NotFound404Exception(responseBody: responseBody);
      case 408:
        return RequestTimeoutException(responseBody: responseBody);
      case 415:
        return UnsupportedMediaTypeException(responseBody: responseBody);
      case 429:
        return TooManyRequestsException(responseBody: responseBody);
    }

    if (statusCode == 444 || statusCode >= 500) {
      return ProblemWithServerException(responseBody: responseBody);
    } else {
      return UnknownHttpException(responseBody: responseBody);
    }
  }

}
