import 'dart:convert';

import '/core/enums/ws_enums.dart' show WSAction, WSActionName, WSChannel;

import 'base_request.dart';

class WSSymbolsRequest extends WSBaseRequest {
  const WSSymbolsRequest({
    required WSAction action,
  }) : super(action: action, channel: WSChannel.symbols);


  WSSymbolsRequest.subscribe()
      : this(action: WSAction.subscribe);
  WSSymbolsRequest.unsubscribe()
      : this(action: WSAction.unsubscribe);

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'WSSymbolsRequest(action: ${action.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSSymbolsRequest &&
        other.action == action &&
        other.channel == WSChannel.symbols;
  }

  @override
  int get hashCode => action.hashCode ^ channel.hashCode;
}
