import '/core/enums/ws_enums.dart' show WSAction, WSActionName, WSChannel, WSChannelName;

abstract class WSBaseRequest {
  const WSBaseRequest({
    required this.action,
    required this.channel,
  });

  /// [action] describes what action to take for the provided channel.
  /// The following standard action's are supported by all channels (with the exception of the auth channel):
  /// * subscribe: Subscribe to the provided channel and attributes
  /// * unsubscribe: Unsubscribe from the provided channel and attributes
  ///
  /// A channel may expose other bespoke actions.
  ///
  /// ref: https://exchange.blockchain.com/api/#action
  final WSAction action;

  /// A channel provides context about the type of data being communicated between the client and server.
  /// There are multiple channels available:
  /// * heartbeat: Receive heartbeat messages
  /// * l2: Receive level 2 order book data (aggregated)
  /// * l3: Receive level 3 order book data (aggregated)
  /// * prices: Receive candlestick market data
  /// * symbols: Receive symbol messages
  /// * ticker: Receive ticker messages
  /// * trades: Receive trade execution messages
  /// * auth: To authenticate a web socket connection
  /// * balances: To receive balance updates
  /// * trading: Submit & cancel orders, receive order snapshots and updates
  ///
  /// ref: https://exchange.blockchain.com/api/#channel
  final WSChannel channel;

  /// converts [action] and [channel] into a `Map<String, dynamic>` data type.
  /// 
  /// returns:
  /// ```dart
  /// {
  ///   'action': action.name,
  ///   'channel': channel.name,
  /// }
  /// ```
  Map<String, String> toMap() {
    return {
      'action': action.name,
      'channel': channel.name,
    };
  }
}
