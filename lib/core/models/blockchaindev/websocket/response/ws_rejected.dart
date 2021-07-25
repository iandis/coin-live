import '/core/enums/ws_enums.dart';
import '/core/models/blockchaindev/websocket/response/base_response.dart';

class WSRejected extends WSBaseResponse {

  const WSRejected({
    required int seqnum,
    required WSChannel channel,
    required this.text,
  }) : super(seqnum: seqnum, event: WSEvent.rejected, channel: channel);

  /// reason for the reject
  final String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is WSRejected &&
      other.seqnum == seqnum &&
      other.event == WSEvent.rejected &&
      other.channel == channel &&
      other.text == text;
  }

  @override
  int get hashCode => seqnum.hashCode ^ event.hashCode ^ channel.hashCode ^ text.hashCode;

  @override
  String toString() => 'WSRejected(seqnum: $seqnum, channel: ${channel.name}, reason: $text)';
}
