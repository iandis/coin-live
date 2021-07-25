import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l3_response.dart';
import '/core/services/navigation_service/base_navigation_service.dart';
import '/views/l3_channel/bloc/l3_channel_bloc.dart';

class L3ChannelScreen extends StatefulWidget {
  final String symbol;
  const L3ChannelScreen({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  _L3ChannelScreenState createState() => _L3ChannelScreenState();
}

class _L3ChannelScreenState extends State<L3ChannelScreen> {
  final _navigationService = GetIt.I<BaseNavigationService>();
  final _l3channelBloc = L3ChannelBloc();

  @override
  void initState() {
    super.initState();
    _l3channelBloc.add(
      SubscribeL3ChannelEvent(widget.symbol),
    );
  }

  @override
  void dispose() {
    _l3channelBloc.add(const UnsubscribeL3ChannelEvent());
    _l3channelBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('L3 Channel: ${widget.symbol}'),
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
        actions: [
          BlocBuilder<L3ChannelBloc, L3ChannelState>(
            bloc: _l3channelBloc,
            builder: (_, state) {
              if (state is L3ChannelInitState ||
                  state is L3ChannelRejectedState ||
                  state is L3ChannelUnsubscribedState) {
                return IconButton(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  onPressed: () => _l3channelBloc.add(
                    SubscribeL3ChannelEvent(widget.symbol),
                  ),
                  icon: const Icon(
                    Icons.wifi_off,
                    color: Colors.white,
                  ),
                );
              } else if (state is L3ChannelSubscribedState ||
                  state is L3ChannelUpdatedState ||
                  state is WebscoketErrorState) {
                return IconButton(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  onPressed: () => _l3channelBloc.add(
                    const UnsubscribeL3ChannelEvent(),
                  ),
                  icon: const Icon(
                    Icons.wifi,
                    color: Colors.white,
                  ),
                );
              }
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const CircularProgressIndicator(
                  color: Colors.lightBlueAccent,
                ),
              );
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: BlocConsumer<L3ChannelBloc, L3ChannelState>(
        bloc: _l3channelBloc,
        listener: (_, state) {
          if (state is WebscoketErrorState) {
            _navigationService.showSnackBar(
              message: 'Websocket error: ${state.errorMessage}',
            );
          } else if (state is L3ChannelRejectedState) {
            _navigationService.showSnackBar(
              message: 'Request rejected: ${state.reason.text}',
            );
          } else if (state is L3ChannelSubscribedState) {
            _navigationService.showSnackBar(
              message: 'Subscribed ${state.symbol} to L3 Channel',
            );
          }
        },
        builder: (_, state) {
          if (state is L3ChannelUpdatedState) {
            return _l3OrderBookList(state);
          } else if (state is! L3ChannelSubscribingState) {
            return const Center(
              child: Text('Waiting for command...'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.lightBlueAccent,
            ),
          );
        },
      ),
    );
  }

  Widget _l3OrderBookList(L3ChannelUpdatedState updatedState) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        MediaQuery.of(context).size.width * 0.025,
        MediaQuery.of(context).size.height * 0.025,
        MediaQuery.of(context).size.width * 0.025,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _bidsList(updatedState.updateResponse.bids),
          const VerticalDivider(),
          _asksList(updatedState.updateResponse.asks),
        ],
      ),
    );
  }

  Widget _bidsList(List<L3Order> bidOrders) {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'Bids',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            shadowColor: Colors.transparent,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => L3OrderBookTile(
                orderDetail: bidOrders[index],
              ),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              childCount: bidOrders.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _asksList(List<L3Order> askOrders) {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text(
              'Asks',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            shadowColor: Colors.transparent,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => L3OrderBookTile(
                orderDetail: askOrders[index],
                isBid: false,
              ),
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              childCount: askOrders.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// final _priceFormatter = NumberFormat.decimalPattern();

class L3OrderBookTile extends StatelessWidget {
  final L3Order orderDetail;
  final bool isBid;

  const L3OrderBookTile(
      {Key? key, required this.orderDetail, this.isBid = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String quantity;
    final String price;
    if (orderDetail.price > 9999 && orderDetail.quantity < 10) {
      quantity = orderDetail.quantity.toStringAsFixed(5);
    } else if (orderDetail.price > 9999 && orderDetail.quantity >= 10) {
      quantity = orderDetail.quantity.toStringAsFixed(4);
    } else if (orderDetail.price > 999 && orderDetail.quantity < 10) {
      quantity = orderDetail.quantity.toStringAsFixed(3);
    } else {
      quantity = orderDetail.quantity.toStringAsFixed(2);
    }
    if (orderDetail.price > 99) {
      price = orderDetail.price.toStringAsFixed(2);
    } else if (orderDetail.price > 0.9) {
      price = orderDetail.price.toStringAsFixed(4);
    } else {
      price = orderDetail.price.toStringAsFixed(6);
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              price,
              style: TextStyle(
                color: isBid ? Colors.greenAccent[700] : Colors.redAccent[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
