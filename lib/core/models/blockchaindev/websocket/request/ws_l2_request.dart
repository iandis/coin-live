
import 'dart:convert';

import '/core/enums/ws_enums.dart' show WSAction, WSActionName, WSChannel;

import 'base_request.dart';

class WSL2Request extends WSBaseRequest {
  const WSL2Request({
    required this.symbol,
    required WSAction action,
  }) : super(action: action, channel: WSChannel.l2);

  final String symbol;

  WSL2Request.subscribe({required String symbol}) : this(symbol: symbol, action: WSAction.subscribe);
  WSL2Request.unsubscribe({required String symbol}) : this(symbol: symbol, action: WSAction.unsubscribe);

  @override
  Map<String, String> toMap() {
    return {
      ...super.toMap(),
      'symbol': symbol,
    };
  }

  String toJson() => json.encode(toMap());


  @override
  String toString() => 'WSL2Request(symbol: $symbol, action: ${action.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is WSL2Request &&
      other.action == action &&
      other.channel == WSChannel.l2 &&
      other.symbol == symbol;
  }

  @override
  int get hashCode => action.hashCode ^ channel.hashCode ^ symbol.hashCode;
}
