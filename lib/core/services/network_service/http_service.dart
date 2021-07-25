import 'dart:async' show FutureOr, TimeoutException;
import 'dart:convert' show Encoding;
import 'dart:io' show SocketException;

import 'package:http/http.dart' show BaseRequest, Client, Response, StreamedResponse;
import 'package:retry/retry.dart' show RetryOptions;

typedef ResponseTimeoutCallback = FutureOr<Response> Function();
typedef StreamedResponseTimeoutCallback = FutureOr<StreamedResponse> Function();

/// a network service class which is an extension of `Client` class.
/// it is by default sets `Duration` of network timeout on every http request and retries 3 times when fails.
/// 
/// it can also help retrieving network status (i.e. connectivity status, internet connection status).
class HTTPService {
  Client _client;
  final Duration _defaultTimeLimit;
  final RetryOptions _retryPolicy;

  /// initializes a new instance of `NetworkService`.
  /// * [defaultTimeLimit] defaults to 10 seconds if not set.
  /// * [retryPolicy] defauts to 3 times if not set.
  HTTPService(Client client, {Duration? defaultTimeLimit, RetryOptions? retryPolicy})
      : _defaultTimeLimit = defaultTimeLimit ?? const Duration(seconds: 10),
        _retryPolicy = retryPolicy ?? const RetryOptions(maxAttempts: 3),
        _client = client;

  ///Closes the client and cleans up any resources associated with it.
  ///
  ///It's important to close each client when it's done being used; failing to do so can cause the Dart process to hang.
  void close() => _client.close();

  /// this will close current `Client`, and create a new one.
  void recreateClient() {
    _client.close();
    _client = Client();
  }

  ///Sends an HTTP GET request with the given headers to the given URL and
  ///a default [timeLimit] of 10 seconds.
  ///
  ///For more fine-grained control over the request, use [send] instead.
  Future<Response> get(Uri url,
      {Map<String, String>? headers,
      Duration? timeLimit,
      ResponseTimeoutCallback? onTimeout}) {
    return _retryPolicy.retry(
      () => _client
        .get(url, headers: headers)
        .timeout(timeLimit ?? _defaultTimeLimit, onTimeout: onTimeout),
      retryIf: (e) => e is SocketException || e is TimeoutException);
  }

  ///Sends an HTTP POST request with the given headers and body to the given URL and
  ///a default [timeLimit] of 10 seconds.
  ///
  ///[body] sets the body of the request.
  ///It can be a [String], a [List] or a [Map<String, String>].
  ///If it's a String, it's encoded using [encoding] and used as the body of the request.
  ///The content-type of the request will default to `"text/plain"`.
  ///
  ///If [body] is a List, it's used as a list of bytes for the body of the request.
  ///
  ///If [body] is a Map, it's encoded as form fields using [encoding].
  ///The content-type of the request will be set to `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  ///[encoding] defaults to [utf8].
  ///
  ///For more fine-grained control over the request, use [send] instead.
  Future<Response> post(Uri url,
      {Map<String, String>? headers,
      Object? body,
      Encoding? encoding,
      Duration? timeLimit,
      ResponseTimeoutCallback? onTimeout}) {
    return _retryPolicy.retry(
      () => _client
        .post(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        )
        .timeout(timeLimit ?? _defaultTimeLimit, onTimeout: onTimeout),
      retryIf: (e) => e is SocketException || e is TimeoutException);
  }

  ///Sends an HTTP PUT request with the given headers and body to the given URL and
  ///a default [timeLimit] of 10 seconds.
  ///
  ///[body] sets the body of the request.
  ///It can be a [String], a [List] or a [Map<String, String>].
  ///If it's a String, it's encoded using [encoding] and used as the body of the request.
  ///The content-type of the request will default to `"text/plain"`.
  ///
  ///If [body] is a List, it's used as a list of bytes for the body of the request.
  ///
  ///If [body] is a Map, it's encoded as form fields using [encoding].
  ///The content-type of the request will be set to `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  ///[encoding] defaults to [utf8].
  ///
  ///For more fine-grained control over the request, use [send] instead.
  Future<Response> put(Uri url,
      {Map<String, String>? headers,
      Object? body,
      Encoding? encoding,
      Duration? timeLimit,
      ResponseTimeoutCallback? onTimeout}) {
    return _retryPolicy.retry(
      () => _client
        .put(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        )
        .timeout(timeLimit ?? _defaultTimeLimit, onTimeout: onTimeout),
      retryIf: (e) => e is SocketException || e is TimeoutException);
  }

  /// Sends an HTTP request with a default [timeLimit] of 10 seconds, and asynchronously returns the response.
  Future<StreamedResponse> send(BaseRequest request,
      {Duration? timeLimit, StreamedResponseTimeoutCallback? onTimeout}) {
    return _retryPolicy.retry(
      () => _client
        .send(request)
        .timeout(timeLimit ?? _defaultTimeLimit, onTimeout: onTimeout),
      retryIf: (e) => e is SocketException || e is TimeoutException);
  }
}
