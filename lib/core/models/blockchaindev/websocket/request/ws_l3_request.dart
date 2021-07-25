import 'dart:convert';

import '/core/enums/ws_enums.dart' show WSAction, WSActionName, WSChannel;

import 'base_request.dart';

class WSL3Request extends WSBaseRequest {
  const WSL3Request({
    required this.symbol,
    required WSAction action,
  }) : super(action: action, channel: WSChannel.l3);

  final String symbol;

  WSL3Request.subscribe({required String symbol})
      : this(symbol: symbol, action: WSAction.subscribe);
  WSL3Request.unsubscribe({required String symbol})
      : this(symbol: symbol, action: WSAction.unsubscribe);

  @override
  Map<String, String> toMap() {
    return {
      ...super.toMap(),
      'symbol': symbol,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'WSL3Request(symbol: $symbol, action: ${action.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSL3Request &&
        other.action == action &&
        other.channel == WSChannel.l3 &&
        other.symbol == symbol;
  }

  @override
  int get hashCode => action.hashCode ^ channel.hashCode ^ symbol.hashCode;
}
