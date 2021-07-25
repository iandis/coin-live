part of 'l2_channel_bloc.dart';

abstract class L2ChannelState extends Equatable {
  final String symbol;
  const L2ChannelState(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class L2ChannelInitState extends L2ChannelState {
  const L2ChannelInitState() : super('');
}

class L2ChannelSubscribingState extends L2ChannelState {
  const L2ChannelSubscribingState(String symbol) : super(symbol);
}

class L2ChannelSubscribedState extends L2ChannelState {
  final WSSubscribedSymbol subscribedResponse;
  const L2ChannelSubscribedState({
    required String symbol,
    required this.subscribedResponse,
  }) : super(symbol);

  @override
  List<Object> get props => [
        ...super.props,
        subscribedResponse,
      ];
}

class L2ChannelUpdatedState extends L2ChannelState {
  final WSL2Response updateResponse;
  const L2ChannelUpdatedState({
    required String symbol,
    required this.updateResponse,
  }) : super(symbol);

  @override
  List<Object> get props => [
        ...super.props,
        updateResponse,
      ];
}

class L2ChannelUnsubscribedState extends L2ChannelState {
  const L2ChannelUnsubscribedState(String symbol) : super(symbol);
}

class L2ChannelRejectedState extends L2ChannelState {
  final WSRejected reason;
  const L2ChannelRejectedState({
    required String symbol,
    required this.reason,
  }) : super(symbol);

  @override
  List<Object> get props => [...super.props, reason];
}

class WebscoketErrorState extends L2ChannelState {
  final String errorMessage;
  const WebscoketErrorState({
    required String symbol,
    required this.errorMessage,
  }) : super(symbol);

  @override
  List<Object> get props => [
        ...super.props,
        errorMessage,
      ];
}
