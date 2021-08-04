import 'dart:convert';

import '/core/enums/ws_enums.dart' show WSAction, WSActionName, WSChannel;

import 'base_request.dart';

class WSTickerRequest extends WSBaseRequest {
  const WSTickerRequest({
    required this.symbol,
    required WSAction action,
  }) : super(action: action, channel: WSChannel.ticker);

  final String symbol;

  WSTickerRequest.subscribe({required String symbol})
      : this(symbol: symbol, action: WSAction.subscribe);
  WSTickerRequest.unsubscribe({required String symbol})
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
  String toString() => 'WSTickerRequest(symbol: $symbol, action: ${action.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSTickerRequest &&
        other.action == action &&
        other.channel == WSChannel.ticker &&
        other.symbol == symbol;
  }

  @override
  int get hashCode => action.hashCode ^ channel.hashCode ^ symbol.hashCode;
}
