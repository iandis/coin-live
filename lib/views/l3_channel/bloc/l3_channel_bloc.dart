import 'dart:async';
import 'dart:developer' as dev show log;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '/core/enums/ws_enums.dart';
import '/core/helpers/ws_msg_parser/base_ws_msg_parser.dart';
import '/core/models/blockchaindev/websocket/request/ws_l3_request.dart';
import '/core/models/blockchaindev/websocket/response/base_response.dart';
import '/core/models/blockchaindev/websocket/response/snapshot_updated/ws_l3_response.dart';
import '/core/models/blockchaindev/websocket/response/subscribed/ws_subscribed_symbol.dart';
import '/core/models/blockchaindev/websocket/response/unsubscribed/ws_unsubscribed_symbol.dart';
import '/core/models/blockchaindev/websocket/response/ws_rejected.dart';
import '/core/services/network_service/websocket_service/base_websocket_service.dart';

part 'l3_channel_event.dart';
part 'l3_channel_state.dart';

typedef JsonMap = Map<String, dynamic>;
typedef L3Event = Stream<L3ChannelEvent>;
typedef L3State = Stream<L3ChannelState>;
typedef L3Transition = Transition<L3ChannelEvent, L3ChannelState>;
typedef L3TransitionFn = TransitionFunction<L3ChannelEvent, L3ChannelState>;
typedef L3TransitionStream = Stream<Transition<L3ChannelEvent, L3ChannelState>>;

class L3ChannelBloc extends Bloc<L3ChannelEvent, L3ChannelState> {
  final _webSocketService = GetIt.I<BaseWebsocketService>();
  late final StreamSubscription<dynamic> _l3channelSubscription;

  L3ChannelBloc() : super(const L3ChannelInitState()) {
    _l3channelSubscription = _webSocketService.listen(
      (data) => _processWebsocketData(
        BaseWSMessageParser().parseResponse(data as String),
      ),
      onError: _processWebsocketError,
    );
  }
  bool _isNonDebounceStates(L3Transition state) {
    return (state.nextState is L3ChannelUpdatedState &&
            !(state.nextState as L3ChannelUpdatedState)
                .updateResponse
                .isUpdatedEvent) ||
        state.nextState is! L3ChannelUpdatedState;
  }

  bool _isDebounceStates(L3Transition state) => !_isNonDebounceStates(state);

  @override
  L3TransitionStream transformTransitions(L3TransitionStream transitions) {
    final nonDebounceStates = transitions.where(_isNonDebounceStates);
    final debounceStates = transitions.where(_isDebounceStates).debounceTime(
          const Duration(milliseconds: 150),
        );
    return nonDebounceStates.mergeWith([debounceStates]);
  }

  @override
  L3State mapEventToState(
    L3ChannelEvent event,
  ) async* {
    if (event is SubscribeL3ChannelEvent) {
      yield* _subscribeL3ChannelEvent(event.symbol);
    } else if (event is SubscribedL3ChannelEvent) {
      yield* _subscribedL3ChannelEvent(event.subscribedResponse);
    } else if (event is UnsubscribeL3ChannelEvent) {
      _unsubscribeL3ChannelEvent();
    } else if (event is UnsubscribedL3ChannelEvent) {
      yield* _unsubscribedL3ChannelEventl();
    } else if (event is UpdatedL3ChannelEvent) {
      if (event.updateResponse.isUpdatedEvent) {
        yield* _updatel3Channel(event.updateResponse);
      } else {
        yield* _snapshotl3Channel(event.updateResponse);
      }
    } else if (event is RejectedL3ChannelEvent) {
      yield* _rejectedL3ChannelEvent(event.rejectedResponse);
    } else if (event is WebsocketErrorEvent) {
      yield* _websocketErrorEvent(event.errorMessage);
    }
  }

  L3State _subscribeL3ChannelEvent(String symbol) async* {
    yield L3ChannelSubscribingState(symbol);
    final l3ChannelSubscribeRequest = WSL3Request.subscribe(
      symbol: symbol,
    ).toJson();
    _webSocketService.add(l3ChannelSubscribeRequest);
  }

  L3State _subscribedL3ChannelEvent(
    WSSubscribedSymbol subscribedResponse,
  ) async* {
    yield L3ChannelSubscribedState(
      symbol: state.symbol,
      subscribedResponse: subscribedResponse,
    );
  }

  void _unsubscribeL3ChannelEvent() {
    final l3ChannelUnsubscribeRequest = WSL3Request.unsubscribe(
      symbol: state.symbol,
    ).toJson();
    _webSocketService.add(l3ChannelUnsubscribeRequest);
  }

  L3State _unsubscribedL3ChannelEventl() async* {
    yield L3ChannelUnsubscribedState(state.symbol);
  }

  L3State _snapshotl3Channel(
    WSL3Response snapshotResponse,
  ) async* {
    yield L3ChannelUpdatedState(
      symbol: state.symbol,
      updateResponse: snapshotResponse,
    );
  }

  L3State _updatel3Channel(
    WSL3Response updateResponse,
  ) async* {
    final currentState = state as L3ChannelUpdatedState;
    yield L3ChannelUpdatedState(
      symbol: currentState.symbol,
      updateResponse: currentState.updateResponse.updatePrices(updateResponse),
    );
  }

  L3State _rejectedL3ChannelEvent(
    WSRejected rejectedResponse,
  ) async* {
    yield L3ChannelRejectedState(
      symbol: state.symbol,
      reason: rejectedResponse,
    );
  }

  L3State _websocketErrorEvent(String errorMessage) async* {
    yield WebscoketErrorState(
      symbol: state.symbol,
      errorMessage: errorMessage,
    );
  }

  void _processWebsocketData(WSBaseResponse wsResponse) {
    if (wsResponse is WSSubscribedSymbol &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l3) {
      add(SubscribedL3ChannelEvent(wsResponse));
    } else if (wsResponse is WSUnsubscribedSymbol &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l3) {
      add(UnsubscribedL3ChannelEvent(wsResponse));
    } else if (wsResponse is WSL3Response &&
        wsResponse.symbol == state.symbol &&
        wsResponse.channel == WSChannel.l3) {
      add(UpdatedL3ChannelEvent(wsResponse));
    } else if (wsResponse is WSRejected && wsResponse.channel == WSChannel.l3) {
      add(RejectedL3ChannelEvent(wsResponse));
    }
  }

  void _processWebsocketError(Object error, StackTrace? stackTrace) {
    add(WebsocketErrorEvent(error.toString()));
    if (kDebugMode) {
      dev.log(
        error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() {
    return _l3channelSubscription.cancel().then((_) => super.close());
  }
}
