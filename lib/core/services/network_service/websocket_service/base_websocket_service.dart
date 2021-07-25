import 'dart:async' show StreamSubscription;

abstract class BaseWebsocketService {

  // Stream get channelStream;
  // Sink get channelSink;

  /// listen for data from server
  StreamSubscription listen(
    void Function(dynamic data)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  });

  /// sends a request to server
  void add(dynamic data);
  
  /// close the channel
  void close([int? closeCode, String? closeReason]);

  Future<void> reestablish();
}
