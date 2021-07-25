import 'dart:convert' as convert show json;


import '/core/enums/ws_enums.dart';

import '/core/models/blockchaindev/websocket/response/base_response.dart';
import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l2_response.dart';
import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l3_response.dart';

import '/core/models/blockchaindev/websocket/response/subscribed/ws_subscribed.dart';
import '/core/models/blockchaindev/websocket/response/subscribed/ws_subscribed_symbol.dart';

import '/core/models/blockchaindev/websocket/response/unsubscribed/ws_unsubcribed.dart';
import '/core/models/blockchaindev/websocket/response/unsubscribed/ws_unsubscribed_symbol.dart';

import '/core/models/blockchaindev/websocket/response/ws_rejected.dart';

import 'base_ws_msg_parser.dart';

class WSMessageParser implements BaseWSMessageParser {
  static const WSMessageParser _instance = WSMessageParser._internal();

  factory WSMessageParser() => _instance;

  const WSMessageParser._internal();

  @override
  // String parseRequest(Object message) => convert.json.encode(message);

  @override
  WSBaseResponse parseResponse(String message) {
    final parsedMessage = convert.json.decode(message) as Map<String, dynamic>;
    final int seqnum = parsedMessage['seqnum'] as int;
    final WSEvent event = WSEvent.values.firstWhere(
      (e) => e.name == (parsedMessage['event'] as String),
    );
    final WSChannel channel = WSChannel.values.firstWhere(
      (c) => c.name == (parsedMessage['channel'] as String),
    );

    switch (event) {
      case WSEvent.rejected:
        return _parseRejected(
          seqnum,
          channel,
          parsedMessage['text'] as String,
        );

      case WSEvent.subscribed:
        return _parseSubscribed(
          seqnum,
          channel,
          parsedMessage['symbol'] as String?,
        );

      case WSEvent.unsubscribed:
        return _parseUnsubscribed(
          seqnum,
          channel,
          parsedMessage['symbol'] as String?,
        );

      case WSEvent.snapshot:
        return _parseSnapshot(
          seqnum,
          channel,
          parsedMessage,
        );

      case WSEvent.updated:
        return _parseUpdated(
          seqnum,
          channel,
          parsedMessage,
        );
    }
  }

  WSRejected _parseRejected(
    int seqnum,
    WSChannel channel,
    String text,
  ) {
    return WSRejected(
      seqnum: seqnum,
      channel: channel,
      text: text,
    );
  }

  WSBaseResponse _parseSubscribed(
    int seqnum,
    WSChannel channel,
    String? symbol,
  ) {
    if (symbol != null) {
      return WSSubscribedSymbol(
        seqnum: seqnum,
        channel: channel,
        symbol: symbol,
      );
    }

    return WSSubscribed(
      seqnum: seqnum,
      channel: channel,
    );
  }

  WSBaseResponse _parseUnsubscribed(
    int seqnum,
    WSChannel channel,
    String? symbol,
  ) {
    if (symbol != null) {
      return WSUnsubscribedSymbol(
        seqnum: seqnum,
        channel: channel,
        symbol: symbol,
      );
    }
    return WSUnsubscribed(
      seqnum: seqnum,
      channel: channel,
    );
  }

  WSBaseResponse _parseSnapshot(
    int seqnum,
    WSChannel channel,
    Map<String, dynamic> parsedMessage,
  ) {
    switch (channel) {

      /// TODO: add all channel `snapshot` events
      case WSChannel.l2:
        return WSL2Response.fromMap(
          map: parsedMessage,
          event: WSEvent.snapshot,
          seqnum: seqnum,
        );
      default:
        return WSL3Response.fromMap(
          map: parsedMessage,
          event: WSEvent.snapshot,
          seqnum: seqnum,
        );
    }
  }

  WSBaseResponse _parseUpdated(
    int seqnum,
    WSChannel channel,
    Map<String, dynamic> parsedMessage,
  ) {
    switch (channel) {

      /// TODO: add all `updated` events
      case WSChannel.l2:
        return WSL2Response.fromMap(
          map: parsedMessage,
          event: WSEvent.updated,
          seqnum: seqnum,
        );
      default:
        return WSL3Response.fromMap(
          map: parsedMessage,
          event: WSEvent.updated,
          seqnum: seqnum,
        );
    }
  }
}
