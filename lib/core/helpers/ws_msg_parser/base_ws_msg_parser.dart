
import '/core/models/blockchaindev/websocket/response/base_response.dart';

import 'ws_msg_parser.dart';

abstract class BaseWSMessageParser {

  factory BaseWSMessageParser() = WSMessageParser;

  WSBaseResponse parseResponse(String message);

  // String parseRequest(Object message);
}