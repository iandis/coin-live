import 'dart:math' show sqrt, max;
import 'package:flutter/material.dart';

import '/core/constants/app_routes.dart';
import '/views/l2_channel/screen/_l2_channel_screen.dart';
import '/views/l3_channel/screen/_l3_channel_screen.dart';
import '/views/main/main_screen.dart';

typedef MQ = MediaQuery;

class ScreenRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        switch (settings.name) {
          case AppRoutes.main:
            return const MainScreen();
          case AppRoutes.l2channel:
            final l2symbol = settings.arguments as String?;
            return L2ChannelScreen(
              symbol: l2symbol ?? 'BTC-USD',
            );
          case AppRoutes.l3channel:
            final l3symbol = settings.arguments as String?;
            return L3ChannelScreen(
              symbol: l3symbol ?? 'BTC-USD',
            );
          default:
            return const Center(
              child: Text(
                "Oops.. The page you're looking for does not exist.",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
        }
      },
      transitionsBuilder: (context, animation, __, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.fastLinearToSlowEaseIn;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return ScaleTransition(
          scale: animation.drive(tween),
          child: ClipPath(
            clipper: _CircularRevealClipper(
              fraction: animation.value,
            ),
            child: child,
          ),
        );
      },
      settings: settings,
    );
  }
}

/// Copyright 2021 Alexander Zhdanov
/// https://github.com/qwert2603
///
/// Licensed under the Apache License, Version 2.0 (the "License");
@immutable
class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Alignment? centerAlignment;
  final Offset? centerOffset;
  final double? minRadius;
  final double? maxRadius;

  const _CircularRevealClipper({
    required this.fraction,
    this.centerAlignment,
    this.centerOffset,
    this.minRadius,
    this.maxRadius,
  });

  @override
  Path getClip(Size size) {
    final Offset center = centerAlignment?.alongSize(size) ??
        centerOffset ??
        Offset(size.width / 2, size.height / 2);
    final minRadius = this.minRadius ?? 0;
    final maxRadius = this.maxRadius ?? calcMaxRadius(size, center);

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: lerpDouble(minRadius, maxRadius, fraction),
        ),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

  static double calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }

  static double lerpDouble(double a, double b, double t) {
    return a * (1.0 - t) + b * t;
  }
}
