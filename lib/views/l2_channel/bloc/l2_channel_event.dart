part of 'l2_channel_bloc.dart';

abstract class L2ChannelEvent extends Equatable {
  const L2ChannelEvent();

  @override
  List<Object> get props => [];
}

class SubscribeL2ChannelEvent extends L2ChannelEvent {
  final String symbol;
  const SubscribeL2ChannelEvent(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class SubscribedL2ChannelEvent extends L2ChannelEvent {
  final WSSubscribedSymbol subscribedResponse;
  const SubscribedL2ChannelEvent(this.subscribedResponse);

  @override
  List<Object> get props => [subscribedResponse];
}

class UpdatedL2ChannelEvent extends L2ChannelEvent {
  final WSL2Response updateResponse;
  const UpdatedL2ChannelEvent(this.updateResponse);

  @override
  List<Object> get props => [updateResponse];
}

class WebsocketErrorEventEvent extends L2ChannelEvent {
  final String errorMessage;
  const WebsocketErrorEventEvent(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class RejectedL2ChannelEvent extends L2ChannelEvent {
  final WSRejected rejectedResponse;
  const RejectedL2ChannelEvent(this.rejectedResponse);
  @override
  List<Object> get props => [rejectedResponse];
}

class UnsubscribeL2ChannelEvent extends L2ChannelEvent {
  const UnsubscribeL2ChannelEvent();
}

class UnsubscribedL2ChannelEvent extends L2ChannelEvent {
  final WSUnsubscribedSymbol unsubscribedResponse;
  const UnsubscribedL2ChannelEvent(this.unsubscribedResponse);
  @override
  List<Object> get props => [unsubscribedResponse];
}
