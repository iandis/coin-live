import 'package:collection/collection.dart' as collection show insertionSort;

import 'package:flutter/foundation.dart' show listEquals;

import '../base_response.dart';

import '/core/enums/ws_enums.dart' show WSEvent, WSChannel;
import '/core/helpers/search_algo_helper.dart';

/// Level 2 Order Book data is available through the `l2` channel.
/// This channel returns the volume available at each price.
/// All the price levels are retrieved with this channel.
/// Subscribing is done per symbol. Each entry in bids and asks arrays is a price level,
/// along with its `price`, `quantity` and `number of orders` attributes.
///
/// ref: https://exchange.blockchain.com/api/#l2-order-book
class WSL2Response extends WSBaseResponse {
  const WSL2Response({
    required int seqnum,
    required WSEvent event,
    required this.symbol,
    required this.bids,
    required this.asks,
  }) : super(seqnum: seqnum, event: event, channel: WSChannel.l2);

  /// the symbol this L2 channel subscribed to
  final String symbol;

  /// available bids (buy) in L2 Order book (descending)
  final List<L2Order> bids;

  /// available asks (sell) in L2 Order book (ascending)
  final List<L2Order> asks;

  bool get isUpdatedEvent => event == WSEvent.updated;

  WSL2Response updatePrices(WSL2Response from) {
    assert(from.symbol == symbol, 'Symbols do not match');
    assert(from.event == WSEvent.updated, 'Event should be `WSEvent.updated`');

    final newBids = bids.toList();
    final newAsks = asks.toList();

    if (from.bids.isNotEmpty) {

      final List<L2Order> fromBidsToBeAdded = [];
      for (final fromBid in from.bids) {
        final findIndex = SearchAlgoHelper.binarySearch<L2Order>(
          newBids,
          where: (currentBid) => fromBid.price.compareTo(currentBid.price),
        );
        if (findIndex > -1) {
          if (fromBid.quantity == 0.0) {
            newBids.removeAt(findIndex);
          } else {
            newBids[findIndex] = fromBid;
          }
        } else {
          fromBidsToBeAdded.add(fromBid);
        }
      }
      newBids.addAll(fromBidsToBeAdded);
      // sort descending
      collection.insertionSort<L2Order>(
        newBids,
        compare: (a, b) => b.price.compareTo(a.price),
      );

      from.bids.clear();
      fromBidsToBeAdded.clear();
    }

    if (from.asks.isNotEmpty) {
      final List<L2Order> fromAsksToBeAdded = [];
      for (final fromAsk in from.asks) {
        final findIndex = SearchAlgoHelper.binarySearch<L2Order>(
          newAsks,
          where: (currentAsk) => currentAsk.price.compareTo(fromAsk.price),
        );
        if (findIndex > -1) {
          if (fromAsk.quantity == 0.0) {
            newAsks.removeAt(findIndex);
          } else {
            newAsks[findIndex] = fromAsk;
          }
        } else {
          fromAsksToBeAdded.add(fromAsk);
        }
      }
      newAsks.addAll(fromAsksToBeAdded);

      // sort ascending
      collection.insertionSort<L2Order>(
        newAsks,
        compare: (a, b) => a.price.compareTo(b.price),
      );

      from.asks.clear();
      fromAsksToBeAdded.clear();
    }

    return WSL2Response(
      seqnum: from.seqnum,
      event: isUpdatedEvent ? event : WSEvent.updated,
      symbol: symbol,
      bids: newBids,
      asks: newAsks,
    );
  }

  factory WSL2Response.fromMap({
    required Map<String, dynamic> map,
    required WSEvent event,
    required int seqnum,
  }) {
    final bidsList = List<L2Order>.from(
      (map['bids'] as List).map(
        (x) => L2Order.fromMap(x as Map<String, dynamic>),
      ),
    );
    final asksList = List<L2Order>.from(
      (map['asks'] as List).map(
        (x) => L2Order.fromMap(x as Map<String, dynamic>),
      ),
    );
    if (event == WSEvent.snapshot) {
      // descending for bids list
      collection.insertionSort<L2Order>(
        bidsList,
        compare: (a, b) => b.price.compareTo(a.price),
      );
      // ascending for asks list
      collection.insertionSort<L2Order>(
        asksList,
        compare: (a, b) => a.price.compareTo(b.price),
      );
    }
    return WSL2Response(
      event: event,
      seqnum: seqnum,
      symbol: map['symbol'] as String,
      bids: bidsList,
      asks: asksList,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSL2Response &&
        other.seqnum == seqnum &&
        other.event == event &&
        other.channel == WSChannel.l2 &&
        other.symbol == symbol &&
        listEquals(other.bids, bids) &&
        listEquals(other.asks, asks);
  }

  @override
  int get hashCode =>
      seqnum.hashCode ^
      event.hashCode ^
      channel.hashCode ^
      symbol.hashCode ^
      bids.hashCode ^
      asks.hashCode;
}

class L2Order {
  const L2Order({
    required this.price,
    required this.quantity,
    required this.numberOfOrders,
  });

  final double price;
  final double quantity;
  final int numberOfOrders;

  factory L2Order.fromMap(Map<String, dynamic> map) {
    return L2Order(
      price: map['px'] as double,
      quantity: map['qty'] as double,
      numberOfOrders: map['num'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is L2Order &&
        other.price == price &&
        other.quantity == quantity &&
        other.numberOfOrders == numberOfOrders;
  }

  @override
  int get hashCode =>
      price.hashCode ^ quantity.hashCode ^ numberOfOrders.hashCode;
}
