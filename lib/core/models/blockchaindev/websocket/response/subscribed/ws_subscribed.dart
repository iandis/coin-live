
import '../base_response.dart';

import '/core/enums/ws_enums.dart';

class WSSubscribed extends WSBaseResponse {

  const WSSubscribed({
    required int seqnum,
    required WSChannel channel,
  }) : super(seqnum: seqnum, event: WSEvent.subscribed, channel: channel);

  @override
  String toString() => 'WSSubscribed(seqnum: $seqnum, channel: ${channel.name})';

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;

    return other is WSSubscribed &&
      other.seqnum == seqnum &&
      other.event == WSEvent.subscribed &&
      other.channel == channel;
  }

  @override
  int get hashCode => seqnum.hashCode ^ event.hashCode ^ channel.hashCode;
}