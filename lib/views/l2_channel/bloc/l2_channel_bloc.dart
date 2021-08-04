import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '/core/enums/ws_enums.dart' show WSChannel;
import '/core/helpers/ws_msg_parser/base_ws_msg_parser.dart';
import '/core/models/blockchaindev/websocket/request/ws_l2_request.dart';
import '/core/models/blockchaindev/websocket/response/base_response.dart';
import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l2_response.dart';
import '/core/models/blockchaindev/websocket/response/subscribed/ws_subscribed_symbol.dart';
import '/core/models/blockchaindev/websocket/response/unsubscribed/ws_unsubscribed_symbol.dart';
import '/core/models/blockchaindev/websocket/response/ws_rejected.dart';
import '/core/services/network_service/websocket_service/base_websocket_service.dart';

part 'l2_channel_event.dart';
part 'l2_channel_state.dart';

typedef JsonMap = Map<String, dynamic>;
typedef L2Event = Stream<L2ChannelEvent>;
typedef L2State = Stream<L2ChannelState>;
typedef L2Transition = Transition<L2ChannelEvent, L2ChannelState>;
typedef L2TransitionFn = TransitionFunction<L2ChannelEvent, L2ChannelState>;
typedef L2TransitionStream = Stream<Transition<L2ChannelEvent, L2ChannelState>>;

class L2ChannelBloc extends Bloc<L2ChannelEvent, L2ChannelState> {
  final _webSocketService = GetIt.I<BaseWebsocketService>();
  late final StreamSubscription<dynamic> _l2channelSubscription;

  L2ChannelBloc() : super(const L2ChannelInitState()) {
    _l2channelSubscription = _webSocketService.listen(
      (data) => _processWebsocketData(
        BaseWSMessageParser().parseResponse(data as String),
      ),
      onError: _processWebsocketErrorEvent,
    );
  }

  // bool _isNonDebounceStates(L2Transition state) {
  //   return (state.nextState is L2ChannelUpdatedState &&
  //           !(state.nextState as L2ChannelUpdatedState)
  //               .updateResponse
  //               .isUpdatedEvent) ||
  //       state.nextState is! L2ChannelUpdatedState;
  // }

  // bool _isDebounceStates(L2Transition state) {
  //   return !_isNonDebounceStates(state);
  // }

  // @override
  // L2TransitionStream transformTransitions(L2TransitionStream transitions) {
  //   final nonDebounceStates = transitions.where(_isNonDebounceStates);

  //   final debounceStates = transitions.where(_isDebounceStates).debounceTime(const Duration(milliseconds: 150));

  //   return nonDebounceStates.mergeWith([debounceStates]);
  // }

  // @override
  // L2TransitionStream transformEvents(
  //   L2Event events,
  //   L2TransitionFn transitionFn,
  // ) {
  //   final nonDebounceEvents = events.where(
  //     (event) => event is! UpdatedL2ChannelEvent,
  //   );

  //   final debouncedEvents = events
  //       .where(
  //         (event) => event is UpdatedL2ChannelEvent,
  //       )
  //       .debounceTime(
  //         const Duration(milliseconds: 500),
  //       );
  //   return super.transformEvents(
  //     nonDebounceEvents.mergeWith([debouncedEvents]),
  //     transitionFn,
  //   ); //.switchMap(transitionFn);
  //   // return nonDebounceEvents.mergeWith([debouncedEvents]).switchMap(transitionFn);
  // }

  @override
  L2State mapEventToState(
    L2ChannelEvent event,
  ) async* {
    if (event is SubscribeL2ChannelEvent) {
      yield* _subscribel2Channel(event.symbol);
    } else if (event is SubscribedL2ChannelEvent) {
      yield* _subscribedl2Channel(event.subscribedResponse);
    } else if (event is UnsubscribeL2ChannelEvent) {
      yield* _unsubscribel2Channel();
    } else if (event is UnsubscribedL2ChannelEvent) {
      yield* _unsubscribedl2Channel();
    } else if (event is UpdatedL2ChannelEvent) {
      if (event.updateResponse.isUpdatedEvent) {
        yield* _updatel2Channel(event.updateResponse);
      } else {
        yield* _snapshotl2Channel(event.updateResponse);
      }
    } else if (event is RejectedL2ChannelEvent) {
      yield* _rejectedl2Channel(event.rejectedResponse);
    } else if (event is WebsocketErrorEventEvent) {
      yield* _websocketErrorEvent(event.errorMessage);
    }
  }

  L2State _subscribel2Channel(String symbol) async* {
    yield L2ChannelSubscribingState(symbol);
    final l2ChannelSubscribeRequest = WSL2Request.subscribe(
      symbol: symbol,
    ).toJson();
    _webSocketService.add(l2ChannelSubscribeRequest);
  }

  L2State _subscribedl2Channel(
    WSSubscribedSymbol subscribedResponse,
  ) async* {
    yield L2ChannelSubscribedState(
      symbol: state.symbol,
      subscribedResponse: subscribedResponse,
    );
  }

  L2State _unsubscribel2Channel() async* {
    yield L2ChannelUnsubscribingState(state.symbol);
    final l3ChannelUnsubscribeRequest = WSL2Request.unsubscribe(
      symbol: state.symbol,
    ).toJson();
    _webSocketService.add(l3ChannelUnsubscribeRequest);
  }

  L2State _unsubscribedl2Channel() async* {
    yield L2ChannelUnsubscribedState(state.symbol);
  }

  L2State _snapshotl2Channel(
    WSL2Response snapshotResponse,
  ) async* {
    yield L2ChannelUpdatedState(
      symbol: state.symbol,
      updateResponse: snapshotResponse,
    );
  }

  L2State _updatel2Channel(
    WSL2Response updateResponse,
  ) async* {
    if (state is L2ChannelUpdatedState) {
      final currentState = state as L2ChannelUpdatedState;

      final updatedResponse =
          currentState.updateResponse.updatePrices(updateResponse);

      yield L2ChannelUpdatedState(
        symbol: currentState.symbol,
        updateResponse: updatedResponse,
      );
    }
  }

  L2State _rejectedl2Channel(
    WSRejected rejectedResponse,
  ) async* {
    yield L2ChannelRejectedState(
      symbol: state.symbol,
      reason: rejectedResponse,
    );
  }

  L2State _websocketErrorEvent(String errorMessage) async* {
    yield WebscoketErrorState(
      symbol: state.symbol,
      errorMessage: errorMessage,
    );
  }

  void _processWebsocketData(WSBaseResponse wsResponse) {
    if (wsResponse is WSSubscribedSymbol &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l2) {
      add(SubscribedL2ChannelEvent(wsResponse));
    } else if (wsResponse is WSUnsubscribedSymbol &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l2) {
      add(UnsubscribedL2ChannelEvent(wsResponse));
    } else if (wsResponse is WSL2Response &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l2 &&
        (state is! L2ChannelUnsubscribingState ||
            state is! L2ChannelUnsubscribedState)) {
      add(UpdatedL2ChannelEvent(wsResponse));
    } else if (wsResponse is WSRejected && wsResponse.channel == WSChannel.l2) {
      add(RejectedL2ChannelEvent(wsResponse));
    }
  }

  void _processWebsocketErrorEvent(Object error, StackTrace? stackTrace) {
    add(WebsocketErrorEventEvent(error.toString()));
    if (kDebugMode) {
      dev.log(
        error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() {
    return _l2channelSubscription.cancel().then((_) => super.close());
  }
}
