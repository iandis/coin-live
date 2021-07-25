part of '_l2_channel_screen.dart';

mixin _L2ChannelScreenWidgets on _L2ChannelScreenProps {
  Widget _l2OrderBookList(L2ChannelUpdatedState updatedState) {
    final bidOrdersLength = updatedState.updateResponse.bids.length;
    final askOrdersLength = updatedState.updateResponse.asks.length;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text(
                'Bids',
                textAlign: TextAlign.center,
              ),
              Text(
                'Asks',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          centerTitle: true,
          snap: true,
          floating: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                return _bidAndAskCombinedTile(
                  index < bidOrdersLength
                      ? updatedState.updateResponse.bids[index]
                      : null,
                  index < askOrdersLength
                      ? updatedState.updateResponse.asks[index]
                      : null,
                );
              },
              childCount: math.max(
                bidOrdersLength,
                askOrdersLength,
              ),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
            ),
          ),
        ),
      ],
    );
    /* Padding(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width * 0.025,
        MediaQuery.of(context).size.height * 0.025,
        MediaQuery.of(context).size.width * 0.025,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bidsList(
            updatedState.updateResponse.bids,
          ),
          const VerticalDivider(),
          _asksList(
            updatedState.updateResponse.asks,
          ),
        ],
      ),
    ); */
  }

  Widget _bidAndAskCombinedTile(L2Order? bidOrder, L2Order? askOrder) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (bidOrder != null)
          L2OrderBookTile(
            orderDetail: bidOrder,
            screenWidth: screenWidth,
          )
        else
          emptySpaceForBidAskList,
        if (askOrder != null)
          L2OrderBookTile(
            orderDetail: askOrder,
            isBid: false,
            screenWidth: screenWidth,
          )
        else
          emptySpaceForBidAskList,
      ],
    );
  }

  // Widget _bidsList(List<L2Order> bidOrders) {
  //   return Expanded(
  //     child: CustomScrollView(
  //       slivers: [
  //         const SliverAppBar(
  //           title: Text(
  //             'Bids',
  //             style: TextStyle(
  //               color: Colors.grey,
  //             ),
  //           ),
  //           automaticallyImplyLeading: false,
  //           backgroundColor: Colors.white,
  //           centerTitle: true,
  //           elevation: 0,
  //           shadowColor: Colors.transparent,
  //           pinned: true,
  //         ),
  //         SliverList(
  //           delegate: SliverChildBuilderDelegate(
  //             (_, index) => L2OrderBookTile(
  //               orderDetail: bidOrders[index],
  //             ),
  //             addAutomaticKeepAlives: false,
  //             addRepaintBoundaries: false,
  //             childCount: bidOrders.length,
  //           ),
  //         ),
  //         const SliverToBoxAdapter(
  //           child: SizedBox(
  //             height: 10,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _asksList(List<L2Order> askOrders) {
  //   return Expanded(
  //     child: CustomScrollView(
  //       slivers: [
  //         const SliverAppBar(
  //           title: Text(
  //             'Asks',
  //             style: TextStyle(
  //               color: Colors.grey,
  //             ),
  //           ),
  //           automaticallyImplyLeading: false,
  //           backgroundColor: Colors.white,
  //           centerTitle: true,
  //           elevation: 0,
  //           shadowColor: Colors.transparent,
  //           pinned: true,
  //         ),
  //         SliverList(
  //           delegate: SliverChildBuilderDelegate(
  //             (_, index) => L2OrderBookTile(
  //               orderDetail: askOrders[index],
  //               isBid: false,
  //             ),
  //             addAutomaticKeepAlives: false,
  //             addRepaintBoundaries: false,
  //             childCount: askOrders.length,
  //           ),
  //         ),
  //         const SliverToBoxAdapter(
  //           child: SizedBox(
  //             height: 10,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

final _priceFormatter = NumberFormat.compact();

class L2OrderBookTile extends StatelessWidget {
  final bool isBid;
  final L2Order orderDetail;
  final double? screenWidth;

  const L2OrderBookTile({
    Key? key,
    required this.orderDetail,
    this.isBid = true,
    this.screenWidth,
  }) : super(key: key);

  String get _quantityToString {
    if (orderDetail.price > 9999 && orderDetail.quantity < 10) {
      return (orderDetail.quantity * orderDetail.numberOfOrders)
          .toStringAsFixed(5);
    } else if (orderDetail.price > 9999 && orderDetail.quantity >= 10) {
      return (orderDetail.quantity * orderDetail.numberOfOrders)
          .toStringAsFixed(4);
    } else if (orderDetail.price > 999 && orderDetail.quantity < 10) {
      return (orderDetail.quantity * orderDetail.numberOfOrders)
          .toStringAsFixed(3);
    }
    return (orderDetail.quantity * orderDetail.numberOfOrders)
        .toStringAsFixed(2);
  }

  String get _priceToString {
    if (orderDetail.price > 99999) {
      return _priceFormatter.format(orderDetail.price);
    } else if (orderDetail.price > 99) {
      return orderDetail.price.toStringAsFixed(2);
    } else if (orderDetail.price > 0.9) {
      return orderDetail.price.toStringAsFixed(4);
    }
    return orderDetail.price.toStringAsFixed(6);
  }

  @override
  Widget build(BuildContext context) {
    final priceText = SizedBox(
      width: (screenWidth ?? MediaQuery.of(context).size.width) * 0.215,
      child: Text(
        _priceToString,
        textAlign: isBid ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isBid ? Colors.greenAccent[700] : Colors.redAccent[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    final quantityText = SizedBox(
      width: (screenWidth ?? MediaQuery.of(context).size.width) * 0.215,
      child: Text(
        _quantityToString,
        textAlign: isBid ? TextAlign.left : TextAlign.right,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isBid) quantityText else priceText,
          if (isBid) priceText else quantityText,
        ],
      ),
    );
  }
}
