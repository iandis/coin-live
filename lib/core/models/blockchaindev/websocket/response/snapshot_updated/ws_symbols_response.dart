import 'dart:convert' show json;

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart' show TimeOfDay;

import '../base_response.dart';
import '/core/enums/ws_enums.dart' hide WSAction, WSActionName;

/// To receive symbol updates, subscribe to the `symbols` channel.
/// The server will send confirmation of the subscription.
/// The next message on this channel will be a snapshot of the current `symbol` status.
///
/// When the `symbol` is not halted the auction data in the message may be blank.
///
/// When a `symbol` is in a halt state the auction data will populate as the book builds.
/// When an opening time has been chosen, the `auction-time` field will show the opening time.
/// Subsequent updates will be sent only if the `symbol` status changes in any way.
///
/// ref: https://exchange.blockchain.com/api/#symbols
class WSSymbolsResponse extends WSBaseResponse {
  const WSSymbolsResponse({
    required int seqnum,
    required WSEvent event,
    required this.symbols,
  }) : super(seqnum: seqnum, event: event, channel: WSChannel.symbols);

  final Map<String, WSSymbolsData> symbols;

  factory WSSymbolsResponse.fromMap({
    required Map<String, dynamic> map,
    required int seqnum,
  }) {
    return WSSymbolsResponse(
      seqnum: seqnum,
      event: WSEvent.snapshot,
      symbols: Map<String, WSSymbolsData>.from(
        (map['symbols'] as Map<String, Map<String, dynamic>>).map(
          (symbol, data) => MapEntry<String, WSSymbolsData>(
            symbol,
            WSSymbolsData.fromMap(data),
          ),
        ),
      ),
    );
  }

  @override
  String toString() =>
      'WSSymbolsResponse(seqnum: $seqnum, event: ${event.name} symbols: $symbols)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSSymbolsResponse &&
        other.seqnum == seqnum &&
        other.event == event &&
        other.channel == WSChannel.symbols &&
        mapEquals(other.symbols, symbols);
  }

  @override
  int get hashCode =>
      seqnum.hashCode ^ event.hashCode ^ channel.hashCode ^ symbols.hashCode;
}

class WSSymbolsData {
  const WSSymbolsData({
    required this.id,
    required this.auctionPrice,
    required this.auctionSize,
    required this.auctionTime,
    required this.baseCurrency,
    required this.baseCurrencyScale,
    required this.counterCurrency,
    required this.counterCurrencyScale,
    required this.imbalance,
    required this.lotSize,
    required this.lotSizeScale,
    required this.minOrderSize,
    required this.minOrderSizeScale,
    required this.maxOrderSize,
    required this.maxOrderSizeScale,
    required this.minPriceIncrement,
    required this.minPriceIncrementScale,
    required this.status,
  });

  /// The symbol's id
  final int id;

  /// If the symbol is halted and will open on an auction, this will be the opening price.
  final double auctionPrice;

  /// Opening size
  final double auctionSize;

  /// Opening time in `HHMM` format
  final TimeOfDay? auctionTime;

  /// The currency quantities are expressed in
  final String baseCurrency;

  /// The number of decimals the currency can be split in
  final int baseCurrencyScale;

  /// The currency prices are expressed in
  final String counterCurrency;

  /// The number of decimals the currency can be split in
  final int counterCurrencyScale;

  /// Auction imbalance. If > 0 then there will be buy orders left over at the auction price.
  /// If < 0 then there will be sell orders left over at the auction price.
  final double imbalance;

  /// Symbol status; open, close, suspend, halt, halt-freeze.
  final WSSymbolStatus status;

  /// The price of the instrument must be a multiple of [minPriceIncrement] * (10^-[minPriceIncrementScale])
  final int minPriceIncrement;

  /// The price of the instrument must be a multiple of [minPriceIncrement] * (10^-[minPriceIncrementScale])
  final int minPriceIncrementScale;

  /// The minimum quantity for an order for this instrument must be [minOrderSize] * (10^-[minOrderSizeScale])
  final int minOrderSize;

  /// The minimum quantity for an order for this instrument must be [minOrderSize] * (10^-[minOrderSizeScale])
  final int minOrderSizeScale;

  /// The maximum quantity for an order for this instrument is
  /// [maxOrderSize] * (10^-[maxOrderSizeScale]).
  /// If this equal to zero, there is no limit
  final int maxOrderSize;

  /// The maximum quantity for an order for this instrument is
  /// [maxOrderSize] * (10^-[maxOrderSizeScale]).
  /// If this equal to zero, there is no limit
  final int maxOrderSizeScale;
  final int lotSize;
  final int lotSizeScale;

  factory WSSymbolsData.fromMap(Map<String, dynamic> map) {
    final parsedAuctionTime = map['auction_time'] as String;
    final _auctionTime = parsedAuctionTime.isNotEmpty
        ? TimeOfDay(
            hour: int.parse(parsedAuctionTime.substring(0, 1)),
            minute: int.parse(parsedAuctionTime.substring(2, 3)),
          )
        : null;
    return WSSymbolsData(
      id: map['id'] as int,
      auctionPrice: map['auction_price'] as double,
      auctionSize: map['auction_size'] as double,
      auctionTime: _auctionTime,
      baseCurrency: map['base_currency'] as String,
      baseCurrencyScale: map['base_currency_scale'] as int,
      counterCurrency: map['counter_currency'] as String,
      counterCurrencyScale: map['counter_currency_scale'] as int,
      imbalance: map['imbalance'] as double,
      status: WSSymbolStatus.values
          .firstWhere((s) => s.name == map['status'] as String),
      minPriceIncrement: map['min_price_increment'] as int,
      minPriceIncrementScale: map['min_price_increment_scale'] as int,
      minOrderSize: map['min_order_size'] as int,
      minOrderSizeScale: map['min_order_size_scale'] as int,
      maxOrderSize: map['max_order_size'] as int,
      maxOrderSizeScale: map['max_order_size_scale'] as int,
      lotSize: map['lot_size'] as int,
      lotSizeScale: map['lot_size_scale'] as int,
    );
  }

  WSSymbolsData updateFromValuesMap(Map<String, dynamic> newValuesMap) {
    final parsedAuctionTime = newValuesMap['auction_time'] as String;
    final _auctionTime = parsedAuctionTime.isNotEmpty
        ? TimeOfDay(
            hour: int.parse(parsedAuctionTime.substring(0, 1)),
            minute: int.parse(parsedAuctionTime.substring(2, 3)),
          )
        : null;
    return WSSymbolsData(
      id: id,
      auctionPrice: newValuesMap['auction_price'] as double? ?? auctionPrice,
      auctionSize: newValuesMap['auction_size'] as double? ?? auctionSize,
      auctionTime: _auctionTime,
      baseCurrency: baseCurrency,
      baseCurrencyScale:
          newValuesMap['base_currency_scale'] as int? ?? baseCurrencyScale,
      counterCurrency: counterCurrency,
      counterCurrencyScale: newValuesMap['counter_currency_scale'] as int? ??
          counterCurrencyScale,
      imbalance: newValuesMap['imbalance'] as double? ?? imbalance,
      status: newValuesMap['status'] != null
          ? WSSymbolStatus.values
              .firstWhere((s) => s.name == newValuesMap['status'] as String)
          : status,
      minPriceIncrement:
          newValuesMap['min_price_increment'] as int? ?? minPriceIncrement,
      minPriceIncrementScale:
          newValuesMap['min_price_increment_scale'] as int? ??
              minPriceIncrementScale,
      minOrderSize: newValuesMap['min_order_size'] as int? ?? minOrderSize,
      minOrderSizeScale:
          newValuesMap['min_order_size_scale'] as int? ?? minOrderSizeScale,
      maxOrderSize: newValuesMap['max_order_size'] as int? ?? maxOrderSize,
      maxOrderSizeScale:
          newValuesMap['max_order_size_scale'] as int? ?? maxOrderSizeScale,
      lotSize: newValuesMap['lot_size'] as int? ?? lotSize,
      lotSizeScale: newValuesMap['lot_size_scale'] as int? ?? lotSizeScale,
    );
  }

  factory WSSymbolsData.fromJson(String source) =>
      WSSymbolsData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'WSSymbolsData(id: $id, auction_price: $auctionPrice, auction_size: $auctionSize, auction_time: $auctionTime, base_currency: $baseCurrency, base_currency_scale: $baseCurrencyScale, counter_currency: $counterCurrency, counter_currency_scale: $counterCurrencyScale, imbalance: $imbalance, status: $status, min_price_increment: $minPriceIncrement, min_price_increment_scale: $minPriceIncrementScale, min_order_size: $minOrderSize, min_order_size_scale: $minOrderSizeScale, max_order_size: $maxOrderSize, max_order_size_scale: $maxOrderSizeScale, lot_size: $lotSize, lot_size_scale: $lotSizeScale)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSSymbolsData &&
        other.id == id &&
        other.auctionPrice == auctionPrice &&
        other.auctionSize == auctionSize &&
        other.auctionTime == auctionTime &&
        other.baseCurrency == baseCurrency &&
        other.baseCurrencyScale == baseCurrencyScale &&
        other.counterCurrency == counterCurrency &&
        other.counterCurrencyScale == counterCurrencyScale &&
        other.imbalance == imbalance &&
        other.status == status &&
        other.minPriceIncrement == minPriceIncrement &&
        other.minPriceIncrementScale == minPriceIncrementScale &&
        other.minOrderSize == minOrderSize &&
        other.minOrderSizeScale == minOrderSizeScale &&
        other.maxOrderSize == maxOrderSize &&
        other.maxOrderSizeScale == maxOrderSizeScale &&
        other.lotSize == lotSize &&
        other.lotSizeScale == lotSizeScale;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        auctionPrice.hashCode ^
        auctionSize.hashCode ^
        auctionTime.hashCode ^
        baseCurrency.hashCode ^
        baseCurrencyScale.hashCode ^
        counterCurrency.hashCode ^
        counterCurrencyScale.hashCode ^
        imbalance.hashCode ^
        status.hashCode ^
        minPriceIncrement.hashCode ^
        minPriceIncrementScale.hashCode ^
        minOrderSize.hashCode ^
        minOrderSizeScale.hashCode ^
        maxOrderSize.hashCode ^
        maxOrderSizeScale.hashCode ^
        lotSize.hashCode ^
        lotSizeScale.hashCode;
  }
}
