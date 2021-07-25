import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

import 'base_websocket_service.dart';

class WebsocketService implements BaseWebsocketService {
  WebsocketService({
    required String wssUrl,
    required Map<String, String> wssHeaders,
  })  : _wssUrl = wssUrl,
        _wssHeaders = wssHeaders,
        _channel = IOWebSocketChannel.connect(
          wssUrl,
          headers: wssHeaders,
        );

  IOWebSocketChannel _channel;

  final String _wssUrl;

  final Map<String, String> _wssHeaders;

  StreamController<dynamic>? _broadcastedController;
  /*  = StreamController<dynamic>.broadcast()
    ..addStream(_channel.stream); */

  // @override
  // Stream<dynamic> get channelStream => _broadcastedController!.stream;

  // @override
  // Sink<dynamic> get channelSink => _channel.sink;

  @override
  StreamSubscription listen(
    void Function(dynamic data)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _broadcastedController ??= StreamController<dynamic>.broadcast()
      ..addStream(_channel.stream);

    return _broadcastedController!.stream.listen(
      onData,
      onDone: onDone,
      onError: onError,
      cancelOnError: cancelOnError,
    );
  }

  @override
  void add(dynamic data) => _channel.sink.add(data);

  @override
  void close([int? closeCode, String? closeReason]) {
    _channel.sink.close(
      closeCode ?? ws_status.goingAway,
      closeReason,
    );
    _broadcastedController?.close();
  }

  @override
  Future<void> reestablish() async {
    if (kDebugMode) {
      dev.log('WebSocket Channel reestablishment requested.\n'
          'Closing WebSocket connection...');
    }
    if (_channel.innerWebSocket != null) {
      await _channel.sink
          .close(ws_status.goingAway)
          .timeout(const Duration(seconds: 5));
    }
    if (kDebugMode) {
      dev.log('WebSocket closed successfully.\nConnecting to $_wssUrl...');
    }
    _channel = IOWebSocketChannel.connect(_wssUrl, headers: _wssHeaders);
    _broadcastedController = StreamController<dynamic>.broadcast()
      ..addStream(_channel.stream);
    if (kDebugMode) {
      dev.log('Connected successfully.');
    }
  }
}
