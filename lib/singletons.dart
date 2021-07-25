
import 'package:coinlive/core/services/navigation_service/base_navigation_service.dart';
import 'package:coinlive/core/services/navigation_service/navigation_service.dart';
import 'package:get_it/get_it.dart';

import '/core/constants/app_apis.dart';

import '/core/services/network_service/websocket_service/base_websocket_service.dart';
import 'core/services/network_service/websocket_service/websocket_service.dart';

void initSingletons() {
  GetIt.I.registerSingleton<AppApis>(AppApis.noApiKeys());
  GetIt.I.registerSingleton<BaseNavigationService>(NavigationService());
  GetIt.I.registerSingleton<BaseWebsocketService>(
    WebsocketService(
      wssUrl: GetIt.I<AppApis>().websocket.baseUrl, 
      wssHeaders: GetIt.I<AppApis>().websocket.baseHeader,
    ),
  );
}