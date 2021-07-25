import 'dart:developer' as dev show log;
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' as foundation show kDebugMode;
import 'package:flutter/material.dart';

import 'base_navigation_service.dart';

typedef PageBuilderFunction = Widget Function(
  BuildContext context,
  Animation<double> a1,
  Animation<double> a2,
);

/// a class to simplify navigating between screens.
/// it requires no `BuildContext` to navigate.
class NavigationService implements BaseNavigationService {
  final _navigatorKey = GlobalKey<NavigatorState>();
  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  @override
  GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  @override
  Future<T?>? toNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    try {
      return navigatorKey.currentState?.pushNamed<T>(
        routeName,
        arguments: arguments,
      );
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(
          e.toString(),
          stackTrace: st,
        );
      }
    }
  }

  @override
  void back<T extends Object?>([T? result]) {
    try {
      return navigatorKey.currentState?.pop(result);
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(
          e.toString(),
          stackTrace: st,
        );
      }
    }
  }

  @override
  void backUntilNamed(String routeName) {
    try {
      return navigatorKey.currentState?.popUntil(
        ModalRoute.withName(routeName),
      );
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(
          e.toString(),
          stackTrace: st,
        );
      }
    }
  }

  @override
  Future<T?>? offToNameUntil<T extends Object?>(
    String toRouteName, {
    required String untilRouteName,
    Object? arguments,
  }) {
    try {
      return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
        toRouteName,
        ModalRoute.withName(untilRouteName),
        arguments: arguments,
      );
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(
          e.toString(),
          stackTrace: st,
        );
      }
    }
  }

  @override
  Future<T?>? offAllToName<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    try {
      return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
        routeName,
        (_) => false,
        arguments: arguments,
      );
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(
          e.toString(),
          stackTrace: st,
        );
      }
    }
  }

  @override
  Future<T?>? offToName<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    try {
      return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
        routeName,
        result: result,
        arguments: arguments,
      );
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(e.toString(), stackTrace: st);
      }
    }
  }

  @override
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
  }) {
    assert(
        (message != null) ^ (content != null),
        'You have to choose between showing a text message or '
        'showing a content which is a widget. If you only want '
        'to show a text message, provide some `String` to the [message], '
        "and don't provide a `Widget` to the [content]. And vice versa.");
    try {
      return messengerKey.currentState?.showSnackBar(SnackBar(
        content: message != null ? Text(message) : content!,
        duration: duration ?? const Duration(milliseconds: 2000),
        backgroundColor: backgroundColor,
        elevation: elevation,
        behavior: floating != null && floating
            ? SnackBarBehavior.floating
            : SnackBarBehavior.fixed,
        margin: margin,
        padding: padding,
        width: width,
        shape: shape,
        action: action,
        animation: animation,
        onVisible: onVisible,
      ));
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(e.toString(), stackTrace: st);
      }
    }
  }

  @override
  Future<T?>? showDialogWithBlur<T extends Object?>({
    required PageBuilderFunction pageBuilder,
    double? blurFactor,
    bool barrierDismissible = false,
    String? barrierLabel,
    Color barrierColor = const Color(0x8A000000),
    Duration transitionDuration = const Duration(milliseconds: 300),
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    assert(
        !barrierDismissible || barrierLabel != null,
        'If you want to set [barrierDismissible] to true, '
        '[barrierLabel] cannot be null, and vice versa.');

    try {
      // final BuildContext? curContext = currentContext;
      if (navigatorKey.currentContext != null) {
        return showGeneralDialog(
          context: navigatorKey.currentContext!,
          pageBuilder: pageBuilder,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          barrierColor: barrierColor,
          transitionDuration: transitionDuration,
          transitionBuilder: blurFactor == null
              ? null
              : (_, a1, __, child) => BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: blurFactor * a1.value,
                        sigmaY: blurFactor * a1.value),
                    child: FadeTransition(
                      opacity: a1,
                      child: child,
                    ),
                  ),
          useRootNavigator: useRootNavigator,
          routeSettings: routeSettings,
        );
      }
    } catch (e, st) {
      if (foundation.kDebugMode) {
        dev.log(e.toString(), stackTrace: st);
      }
    }
  }
}
