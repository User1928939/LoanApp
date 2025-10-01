import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    debugPrint('Navigation: replacing to $routeName');
    try {
      return navigatorKey.currentState!.pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      rethrow;
    }
  }

  Future<dynamic> pushAndClearStack(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  void goBackWithResult(dynamic result) {
    return navigatorKey.currentState!.pop(result);
  }

  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }
}
