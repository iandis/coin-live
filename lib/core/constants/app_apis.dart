import 'dart:convert' show json;

import 'package:flutter/services.dart' show rootBundle;

typedef JsonMap = Map<String, dynamic>;

class _WebSocketAPIs {
  const _WebSocketAPIs();

  Map<String, String> get baseHeader {
    return const {
      'origin': 'https://exchange.blockchain.com',
    };
  }

  String get baseUrl => 'wss://ws.prod.blockchain.info/mercury-gateway/v1/ws';

}

class AppApis {
  final String apiKey;
  final String apiSecret;
  _WebSocketAPIs get websocket => const _WebSocketAPIs();

  const AppApis({
    required this.apiKey,
    required this.apiSecret,
  });

  factory AppApis.noApiKeys() => const AppApis(apiKey: '', apiSecret: '');

  /// call this to get an [AppApis] instance
  /// with its keys
  static Future<AppApis> loadApiKeys() async {
    final JsonMap loadedKeys = await rootBundle.loadStructuredData<JsonMap>(
      'assets/apikeys.json',
      (keys) async => json.decode(keys) as Map<String, dynamic>,
    );

    return AppApis(
      apiKey: loadedKeys['key'] as String,
      apiSecret: loadedKeys['secret'] as String,
    );
  }
}
