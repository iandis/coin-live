import 'package:coinlive/core/services/navigation_service/base_navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '/core/constants/app_routes.dart';
import '/core/helpers/screen_router.dart';
import 'singletons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initSingletons();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coinlive by Iandi',
      debugShowCheckedModeBanner: false,
      navigatorKey: GetIt.I<BaseNavigationService>().navigatorKey,
      scaffoldMessengerKey: GetIt.I<BaseNavigationService>().messengerKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.main,
      onGenerateRoute: ScreenRouter.onGenerateRoute,
    );
  }
}
