part of 'l3_channel_bloc.dart';

abstract class L3ChannelState extends Equatable {
  final String symbol;
  const L3ChannelState(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class L3ChannelInitState extends L3ChannelState {
  const L3ChannelInitState() : super('');
}

class L3ChannelSubscribingState extends L3ChannelState {
  const L3ChannelSubscribingState(String symbol) : super(symbol);
}

class L3ChannelSubscribedState extends L3ChannelState {
  final WSSubscribedSymbol subscribedResponse;
  const L3ChannelSubscribedState({
    required String symbol,
    required this.subscribedResponse,
  }) : super(symbol);

  @override
  List<Object> get props => [
        ...super.props,
        subscribedResponse,
      ];
}

class L3ChannelUpdatedState extends L3ChannelState {
  final WSL3Response updateResponse;
  const L3ChannelUpdatedState({
    required String symbol,
    required this.updateResponse,
  }) : super(symbol);

  @override
  List<Object> get props => [
        ...super.props,
        updateResponse,
      ];
}

class L3ChannelUnsubscribedState extends L3ChannelState {
  const L3ChannelUnsubscribedState(String symbol) : super(symbol);
}

class L3ChannelRejectedState extends L3ChannelState {
  final WSRejected reason;
  const L3ChannelRejectedState({
    required String symbol,
    required this.reason,
  }) : super(symbol);

  @override
  List<Object> get props => [...super.props, reason];
}

class WebscoketErrorState extends L3ChannelState {
  final String errorMessage;
  const WebscoketErrorState({
    required String symbol,
    required this.errorMessage,
  }) : super(symbol);

  @override
  List<Object> get props => [...super.props, errorMessage];
}
