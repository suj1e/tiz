import 'package:flutter/material.dart';

enum SlideDirection {
  right,
  left,
  up,
  down,
}

/// Helper functions for iOS-style navigation
class NavigationHelper {
  /// Push with iOS-style fade + scale transition
  static Future<T?> pushIOS<T extends Object?>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
            reverseCurve: Curves.easeIn,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                  reverseCurve: Curves.easeIn,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  /// Push replacement with iOS-style transition
  static Future<T?> pushReplacementIOS<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
            reverseCurve: Curves.easeIn,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                  reverseCurve: Curves.easeIn,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
      result: result,
    );
  }

  /// Push and remove all previous routes with iOS-style transition
  static Future<T?> pushAndRemoveUntilIOS<T extends Object?>(
    BuildContext context,
    Widget page,
    RoutePredicate predicate,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
            reverseCurve: Curves.easeIn,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: curve,
                  reverseCurve: Curves.easeIn,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
      predicate,
    );
  }

  /// Slide + Fade transition
  static Future<T?> pushSlideFade<T extends Object?>(
    BuildContext context,
    Widget page, {
    SlideDirection direction = SlideDirection.right,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = Curves.easeOut;
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
            reverseCurve: Curves.easeIn,
          );

          // Calculate slide offset based on direction
          Offset begin;
          switch (direction) {
            case SlideDirection.right:
              begin = const Offset(1.0, 0.0);
              break;
            case SlideDirection.left:
              begin = const Offset(-1.0, 0.0);
              break;
            case SlideDirection.up:
              begin = const Offset(0.0, 1.0);
              break;
            case SlideDirection.down:
              begin = const Offset(0.0, -1.0);
              break;
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
