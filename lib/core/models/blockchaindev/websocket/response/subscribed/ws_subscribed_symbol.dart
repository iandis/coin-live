

import '../base_response.dart';

import '/core/enums/ws_enums.dart';

class WSSubscribedSymbol extends WSBaseResponse {
  const WSSubscribedSymbol({
    required int seqnum,
    required WSChannel channel,
    required this.symbol,
  }) : super(seqnum: seqnum, event: WSEvent.subscribed, channel: channel);

  /// the symbol this channel subscribed to
  final String symbol;

  @override
  String toString() =>
      'WSSubscribedSymbol(seqnum: $seqnum, channel: ${channel.name}, symbol: $symbol)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSSubscribedSymbol &&
        other.seqnum == seqnum &&
        other.event == WSEvent.subscribed &&
        other.channel == channel &&
        other.symbol == symbol;
  }

  @override
  int get hashCode => seqnum.hashCode ^ event.hashCode ^ channel.hashCode ^ symbol.hashCode;
}
