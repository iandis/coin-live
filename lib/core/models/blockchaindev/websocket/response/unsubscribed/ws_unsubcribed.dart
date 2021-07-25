
import '../base_response.dart';

import '/core/enums/ws_enums.dart';

class WSUnsubscribed extends WSBaseResponse {
  const WSUnsubscribed({
    required int seqnum,
    required WSChannel channel,
  }) : super(seqnum: seqnum, event: WSEvent.unsubscribed, channel: channel);

  @override
  String toString() => 'WSUnsubscribed(seqnum: $seqnum, channel: ${channel.name})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WSUnsubscribed &&
        other.seqnum == seqnum &&
        other.event == WSEvent.unsubscribed &&
        other.channel == channel;
  }

  @override
  int get hashCode => seqnum.hashCode ^ event.hashCode ^ channel.hashCode;
}
