
import 'package:flutter/material.dart';

typedef PageBuilderFunction = Widget Function(
  BuildContext context,
  Animation<double> a1,
  Animation<double> a2,
);

abstract class BaseNavigationService {
  /// the navigator key responsible for navigating between screens
  GlobalKey<NavigatorState> get navigatorKey;
  /// the scaffold messenger key responsible for showing snackbar
  GlobalKey<ScaffoldMessengerState> get messengerKey;
  /// this is equivalent to
  /// ```
  /// await Navigator.of(contex).pushNamed('/routeName');
  /// ```
  Future<T?>? toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  });
  /// this is equivalent to
  /// ```dart
  /// Navigator.of(contex).pop();
  /// ```
  void back<T extends Object?>([T? result]);
  /// this is equivalent to
  /// ```dart
  /// Navigator.of(context).popUntil(ModalRoute.withName('\routeName'));
  /// ```
  void backUntilNamed(String routeName);
  /// this is equivalent to
  /// ```dart
  /// await Navigator.of(contex).pushNamedAndRemoveUntil('/routeName', ModalRoute.withName('/untilRouteName'), arguments: arguments);
  /// ```
  Future<T?>? offToNameUntil<T extends Object?>(
    String toRouteName, {
    required String untilRouteName,
    Object? arguments,
  });
  /// this is equivalent to
  /// ```dart
  /// await Navigator.of(contex).pushNamedAndRemoveUntil('/routeName', (_) => false, arguments: arguments);
  /// ```
  Future<T?>? offAllToName<T extends Object?>(
    String routeName, {
    Object? arguments,
  });
  /// this is equivalent to
  /// ```dart
  /// await Navigator.of(contex).pushReplacementNamed('/routeName');
  /// ```
  Future<T?>? offToName<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  });
  /// a shortcut for showing snack bar.
  ///
  /// provide either a `String` [message] or a `Widget` [content].
  /// one of them cannot be `null`.
  ///
  /// [duration] defaults to 2000 ms
  ///
  /// [floating] is used whether to show snackbar floating above all widgets
  /// including [BottomNavigationBar] and [FloatingActionButton].
  /// defaults to false: [SnackBarBehavior.fixed].
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar({
    String? message,
    Widget? content,
    Duration? duration,
    Color backgroundColor = const Color(0xFF01579B),
    double? elevation,
    bool? floating,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? width,
    ShapeBorder? shape,
    SnackBarAction? action,
    Animation<double>? animation,
    void Function()? onVisible,
  });
  /// [blurFactor] defaults to `null` which means no blur
  Future<T?>? showDialogWithBlur<T extends Object?>({
    required PageBuilderFunction pageBuilder,
    double? blurFactor,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x8A000000),
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  });
}