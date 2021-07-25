part of 'l3_channel_bloc.dart';

abstract class L3ChannelEvent extends Equatable {
  const L3ChannelEvent();

  @override
  List<Object> get props => [];
}

class SubscribeL3ChannelEvent extends L3ChannelEvent {
  final String symbol;
  const SubscribeL3ChannelEvent(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class SubscribedL3ChannelEvent extends L3ChannelEvent {
  final WSSubscribedSymbol subscribedResponse;
  const SubscribedL3ChannelEvent(this.subscribedResponse);

  @override
  List<Object> get props => [subscribedResponse];
}

class UpdatedL3ChannelEvent extends L3ChannelEvent {
  final WSL3Response updateResponse;
  const UpdatedL3ChannelEvent(this.updateResponse);

  @override
  List<Object> get props => [updateResponse];
}

class WebsocketErrorEvent extends L3ChannelEvent {
  final String errorMessage;
  const WebsocketErrorEvent(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

class RejectedL3ChannelEvent extends L3ChannelEvent {
  final WSRejected rejectedResponse;
  const RejectedL3ChannelEvent(this.rejectedResponse);
  @override
  List<Object> get props => [rejectedResponse];
}

class UnsubscribeL3ChannelEvent extends L3ChannelEvent {
  const UnsubscribeL3ChannelEvent();
}

class UnsubscribedL3ChannelEvent extends L3ChannelEvent {
  final WSUnsubscribedSymbol unsubscribedResponse;
  const UnsubscribedL3ChannelEvent(this.unsubscribedResponse);
  @override
  List<Object> get props => [unsubscribedResponse];
}
