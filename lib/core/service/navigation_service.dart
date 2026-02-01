import 'package:flutter/material.dart';

/// Service for app-level navigation using a global navigator key.
///
/// Use [navigatorKey] when building [MaterialApp] and call navigation
/// methods from anywhere without [BuildContext].
class NavigationService {
  NavigationService() : _navigatorKey = GlobalKey<NavigatorState>();

  final GlobalKey<NavigatorState> _navigatorKey;

  /// Key to pass to [MaterialApp.navigatorKey].
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  NavigatorState? get _navigator => _navigatorKey.currentState;

  /// Pushes [route] onto the navigation stack.
  Future<T?> push<T extends Object?>(Route<T> route) {
    final navigator = _navigator;
    if (navigator == null) return Future<T?>.value(null);
    return navigator.push(route);
  }

  /// Pops the current route off the stack, optionally with [result].
  void pop<T extends Object?>([T? result]) {
    _navigator?.pop(result);
  }

  /// Pops the current route if possible. Returns true if a route was popped.
  Future<bool> maybePop<T extends Object?>([T? result]) {
    final navigator = _navigator;
    if (navigator == null) return Future<bool>.value(false);
    return navigator.maybePop(result);
  }

  /// Replaces the current route with [route].
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> route, {
    TO? result,
  }) {
    final navigator = _navigator;
    if (navigator == null) return Future<T?>.value(null);
    return navigator.pushReplacement(route, result: result);
  }

  /// Pops until a route with [predicate] returns true.
  void popUntil(RoutePredicate predicate) {
    _navigator?.popUntil(predicate);
  }

  /// Pops all routes until the first route.
  void popUntilFirst() {
    popUntil((route) => route.isFirst);
  }

  /// Pushes a named route onto the stack.
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    final navigator = _navigator;
    if (navigator == null) return Future<T?>.value(null);
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces the current route with a named route.
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    final navigator = _navigator;
    if (navigator == null) return Future<T?>.value(null);
    return navigator.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }
}
