import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l2_response.dart';
import '/core/services/navigation_service/base_navigation_service.dart';
import '/views/l2_channel/bloc/l2_channel_bloc.dart';

part 'l2_channel_props.dart';
part 'l2_channel_widgets.dart';

class L2ChannelScreen extends StatefulWidget {
  final String symbol;
  const L2ChannelScreen({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  _L2ChannelScreenState createState() => _L2ChannelScreenState();
}

class _L2ChannelScreenState extends _L2ChannelScreenProps
    with _L2ChannelScreenWidgets {
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    emptySpaceForBidAskList = SizedBox(
      width: screenWidth * 0.43,
    );
    Widget l2LoadButtonBuilder(BuildContext context, L2ChannelState state) {
      if (state is! L2ChannelUpdatedState) {
        return IconButton(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          onPressed: () => _l2channelBloc.add(
            SubscribeL2ChannelEvent(widget.symbol),
          ),
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
          ),
        );
      } else if (state is L2ChannelSubscribedState ||
          state is L2ChannelUpdatedState ||
          state is WebscoketErrorState) {
        return IconButton(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          onPressed: () => _l2channelBloc.add(
            const UnsubscribeL2ChannelEvent(),
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
    }

    void l2StateListener(BuildContext context, L2ChannelState state) {
      if (state is WebscoketErrorState) {
        _navigationService.showSnackBar(
          message: 'Websocket error: ${state.errorMessage}',
        );
      } else if (state is L2ChannelRejectedState) {
        _navigationService.showSnackBar(
          message: 'Request rejected: ${state.reason.text}',
        );
      } else if (state is L2ChannelSubscribedState) {
        _navigationService.showSnackBar(
          message: 'Subscribed ${state.symbol} to L2 Channel',
        );
      }
    }

    Widget l2StateBuilder(BuildContext context, L2ChannelState state) {
      if (state is L2ChannelUpdatedState) {
        return _l2OrderBookList(state);
      } else if (state is! L2ChannelSubscribingState) {
        return const Center(
          child: Text(
            'Please click the Wifi icon to start',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        );
      }
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlueAccent,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => onBackPressed(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('L2 Channel: ${widget.symbol}'),
          elevation: 0,
          actions: [
            BlocBuilder<L2ChannelBloc, L2ChannelState>(
              bloc: _l2channelBloc,
              builder: l2LoadButtonBuilder,
            ),
          ],
          leading: IconButton(
            onPressed: () => onBackPressed() ? Navigator.of(context).pop() : null,
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: BlocConsumer<L2ChannelBloc, L2ChannelState>(
          bloc: _l2channelBloc,
          listener: l2StateListener,
          builder: l2StateBuilder,
          // buildWhen: (prev, next) {
          //   if ((prev is L2ChannelUnsubscribingState || prev is L2ChannelUnsubscribedState)  &&
          //       next is L2ChannelUpdatedState) {
          //     return false;
          //   }
          //   return true;
          // },
        ),
      ),
    );
  }
}
