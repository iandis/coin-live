
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  test('Test WebSocketChannel', () async {
    final WebSocketChannel websocketChannel = IOWebSocketChannel.connect(
      'wss://ws.prod.blockchain.info/mercury-gateway/v1/ws',
      headers: {
        // 'Connection': 'upgrade',
        // 'Upgrade': 'websocket',
        // // 'Content-Length': 0,
        // 'Sec-WebSocket-Version': 13,
        // 'Sec-WebSocket-Extensions': 'permessage-deflate; client_max_window_bits',
        'Origin': 'https://exchange.blockchain.com',
      },
      //protocols: ['https://exchange.blockchain.com'],
    );

    websocketChannel.sink.add('ada');

    websocketChannel.stream.listen((value) {
      // ignore: avoid_print
      print(value);
    }, cancelOnError: true);
    // sub.onError((e) async {
    //   print(e);
    //   await sub.cancel();
    //   print('called cancel');
    //   // await websocketChannel.sink.close();
    //   // print('called close');
    // });
    // sub.onError((e, st) {
    //   sub.cancel();
    //   websocketChannel.sink.close(status.goingAway);
    // });
    // sub.onError((e, st) {
    //   print(e);
    //   print(st);
    //   websocketChannel.sink.close(status.goingAway);
    //   sub.cancel();
    // });
    // sub.onDone(() => websocketChannel.sink.close(status.goingAway));


    await Future.delayed(const Duration(seconds: 10), websocketChannel.sink.close);

  });
}