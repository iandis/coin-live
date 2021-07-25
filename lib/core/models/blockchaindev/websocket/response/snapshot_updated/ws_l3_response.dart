import 'package:collection/collection.dart' as collection show insertionSort;

import 'package:flutter/foundation.dart' show listEquals;

import '../base_response.dart';

import '/core/enums/ws_enums.dart' show WSEvent, WSChannel;

/// Level 3 Order Book data is available through the `l3` channel.
/// This channel returns all the order updates reaching the exchange;
/// by applying the updates to the snapshot you can recreate the full state of the orderbook.
/// Subscribing is done per symbol. Each entry in bids and asks arrays is an order,
/// along with its `id`, `price` and `quantity` attributes.
///
/// ref: https://exchange.blockchain.com/api/#l3-order-book
class WSL3Response extends WSBaseResponse {
  const WSL3Response({
    required int seqnum,
    required WSEvent event,
    required this.symbol,
    required this.bids,
    required this.asks,
  }) : super(seqnum: seqnum, event: event, channel: WSChannel.l3);

  /// the symbol this L2 channel subscribed to
  final String symbol;

  /// available bids (buy) in L3 Order book (descending)
  final List<L3Order> bids;

  /// available asks (sell) in L3 Order book (ascending)
  final List<L3Order> asks;

  bool get isUpdatedEvent => event == WSEvent.updated;

  WSL3Response updatePrices(WSL3Response from) {
    assert(from.symbol == symbol, 'Symbols do not match');
    assert(from.event == WSEvent.updated, 'Event should be `WSEvent.updated`');

    final newBids = bids.toList();
    final newAsks = asks.toList();

    if (from.bids.isNotEmpty) {
      // // sort descending if length >= 2
      // if (from.bids.length >= 2) {
      //   collection.insertionSort<L3Order>(
      //     from.bids,
      //     compare: (a, b) => b.price.compareTo(a.price),
      //   );
      // }

      final List<L3Order> fromBidsToBeAdded = [];
      for (final fromBid in from.bids) {
        final findIndex = newBids.indexWhere((bid) => bid.id == fromBid.id); /* SearchAlgoHelper.binarySearch<L3Order>(
          newBids,
          where: (currentBid) => fromBid.price.compareTo(currentBid.price),
        ); */
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
      collection.insertionSort<L3Order>(
        newBids,
        compare: (a, b) => b.price.compareTo(a.price),
      );

      // bids.clear();
      from.bids.clear();
      fromBidsToBeAdded.clear();
    }

    if (from.asks.isNotEmpty) {
      final List<L3Order> fromAsksToBeAdded = [];
      for (final fromAsk in from.asks) {
        final findIndex = newAsks.indexWhere((ask) => ask.id == fromAsk.id); /* SearchAlgoHelper.binarySearch<L3Order>(
          newAsks,
          where: (currentAsk) => currentAsk.price.compareTo(fromAsk.price),
        ); */
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
      collection.insertionSort<L3Order>(
        newAsks,
        compare: (a, b) => a.price.compareTo(b.price),
      );

      from.asks.clear();
      fromAsksToBeAdded.clear();
    }

    return WSL3Response(
      seqnum: from.seqnum,
      event: isUpdatedEvent ? event : WSEvent.updated,
      symbol: symbol,
      bids: newBids,
      asks: newAsks,
    );
  }

  factory WSL3Response.fromMap({
    required Map<String, dynamic> map,
    required WSEvent event,
    required int seqnum,
  }) {
    final bidsList = List<L3Order>.from(
      (map['bids'] as List).map(
        (x) => L3Order.fromMap(x as Map<String, dynamic>),
      ),
    );
    final asksList = List<L3Order>.from(
      (map['asks'] as List).map(
        (x) => L3Order.fromMap(x as Map<String, dynamic>),
      ),
    );
    if (event == WSEvent.snapshot) {
      // descending for bids list
      collection.insertionSort<L3Order>(
        bidsList,
        compare: (a, b) => b.price.compareTo(a.price),
      );
      // ascending for asks list
      collection.insertionSort<L3Order>(
        asksList,
        compare: (a, b) => a.price.compareTo(b.price),
      );
    }
    return WSL3Response(
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

    return other is WSL3Response &&
        other.seqnum == seqnum &&
        other.event == event &&
        other.channel == WSChannel.l3 &&
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

class L3Order {
  const L3Order({
    required this.id,
    required this.price,
    required this.quantity,
  });

  final String id;
  final double price;
  final double quantity;

  factory L3Order.fromMap(Map<String, dynamic> map) {
    return L3Order(
      id: map['id'] as String,
      price: map['px'] as double,
      quantity: map['qty'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is L3Order &&
        other.id == id &&
        other.price == price &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => price.hashCode ^ quantity.hashCode ^ id.hashCode;
}
