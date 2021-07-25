import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '/core/constants/app_routes.dart';
import '/core/services/network_service/websocket_service/base_websocket_service.dart';

typedef VLBuilder<T> = ValueListenableBuilder<T>;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final coinSymbolController = TextEditingController(text: 'BTC-USD');
  final isReestablishingConnection = ValueNotifier(false);

  @override
  void dispose() {
    GetIt.I<BaseWebsocketService>().close();
    isReestablishingConnection.dispose();
    coinSymbolController.dispose();
    super.dispose();
  }

  // ignore: avoid_void_async
  void _reestablishWSConnection() async {
    if(isReestablishingConnection.value) return;
    isReestablishingConnection.value = true;
    await GetIt.I<BaseWebsocketService>().reestablish();
    isReestablishingConnection.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: VLBuilder<TextEditingValue>(
          valueListenable: coinSymbolController,
          builder: (_, symbol, __) => Text('Coinlive: ${symbol.text}'),
        ),
        actions: [
          VLBuilder<bool>(
            valueListenable: isReestablishingConnection,
            builder: (_, isReestablishing, icon) {
              return IconButton(
                onPressed: isReestablishing
                    ? null
                    : _reestablishWSConnection,
                icon: icon!,
              );
            },
            child: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: coinSymbolController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.l2channel,
                arguments: coinSymbolController.text,
              ),
              child: const Text('Goto L2 Channel'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.l3channel,
                arguments: coinSymbolController.text,
              ),
              child: const Text('Goto L3 Channel'),
            ),
          ],
        ),
      ),
    );
  }
}
