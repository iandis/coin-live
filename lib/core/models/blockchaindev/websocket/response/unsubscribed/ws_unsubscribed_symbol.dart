import '../base_response.dart';

import '/core/enums/ws_enums.dart';

class WSUnsubscribedSymbol extends WSBaseResponse {
  const WSUnsubscribedSymbol({
    required int seqnum,
    required WSChannel channel,
    required this.symbol,
  }) : super(seqnum: seqnum, event: WSEvent.unsubscribed, channel: channel);

  /// the symbol this channel unsubscribed to
  final String symbol;

  @override
  String toString() =>
      'WSUnsubscribedSymbol(seqnum: $seqnum, channel: ${channel.name}, symbol: $symbol)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSUnsubscribedSymbol &&
        other.seqnum == seqnum &&
        other.event == WSEvent.unsubscribed &&
        other.channel == channel &&
        other.symbol == symbol;
  }

  @override
  int get hashCode => seqnum.hashCode ^ event.hashCode ^ channel.hashCode ^ symbol.hashCode;
}
