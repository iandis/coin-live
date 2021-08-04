import '../base_response.dart';
import '/core/enums/ws_enums.dart' hide WSAction, WSActionName;

/// In order to receive `ticker` updates, ticker channel is available.
/// Subscriptions are again per symbol. The server will send confirmation of the subscription.
class WSTickerSnapshot extends WSBaseResponse {
  const WSTickerSnapshot({
    required int seqnum,
    required this.symbol,
    required this.price24h,
    required this.volume24h,
    required this.lastTradePrice,
  }) :  super(
          seqnum: seqnum,
          event: WSEvent.snapshot,
          channel: WSChannel.ticker,
        );

  final String symbol;
  final double price24h;
  final double volume24h;
  final double lastTradePrice;

  factory WSTickerSnapshot.fromMap({
    required Map<String, dynamic> map,
    required int seqnum,
  }) {
    return WSTickerSnapshot(
      seqnum: seqnum,
      symbol: map['symbol'] as String,
      price24h: map['price_24h'] as double,
      volume24h: map['volume_24h'] as double,
      lastTradePrice: map['last_trade_price'] as double,
    );
  }

  @override
  String toString() {
    return 'WSTickerSnapshot(symbol: $symbol, price24h: $price24h, volume24h: $volume24h, lastTradePrice: $lastTradePrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSTickerSnapshot &&
        other.seqnum == seqnum &&
        other.event == WSEvent.snapshot &&
        other.channel == WSChannel.ticker &&
        other.symbol == symbol &&
        other.price24h == price24h &&
        other.volume24h == volume24h &&
        other.lastTradePrice == lastTradePrice;
  }

  @override
  int get hashCode {
    return seqnum.hashCode ^
        event.hashCode ^
        channel.hashCode ^
        symbol.hashCode ^
        price24h.hashCode ^
        volume24h.hashCode ^
        lastTradePrice.hashCode;
  }
}
