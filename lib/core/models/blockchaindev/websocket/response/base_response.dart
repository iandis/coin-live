import 'package:coinlive/core/enums/ws_enums.dart';

abstract class WSBaseResponse {
  const WSBaseResponse({
    required this.seqnum,
    required this.event,
    required this.channel,
  });

  /// Each message sent from the server will contain a [seqnum],
  /// which will be incremented by 1 with each message.
  /// If the client receives a [seqnum] which has skipped one or more sequences,
  /// it indicates that a message was missed and the client is recommended to restart the websocket connection.
  ///
  /// ref: https://exchange.blockchain.com/api/#sequence-numbers
  final int seqnum;

  /// In addition, each response field will contain an event field with
  /// the corresponding channel to indicate the purpose of the message.
  /// The following events are supported:
  /// * subscribed: The channel was successfully subscribed to
  /// * unsubscribed: The channel was successfully unsubscribed to
  /// * rejected: the last action for the channel was rejected. A text field will be provided about the reason for the reject
  /// * snapshot: A channel snapshot has been provided
  /// * updated: An update corresponding to the channel has occurred
  ///
  /// ref: https://exchange.blockchain.com/api/#event
  final WSEvent event;

  /// the channel where this response is coming from.
  final WSChannel channel;

}
