import 'package:flutter/widgets.dart';

abstract class AjanuwNavigatorBase {
  static final String baseHref = '/';
  Route<T> onGenerateRoute<T>(RouteSettings settings);
  List<Route<dynamic>> history = [];

  /// ```dart
  /// // example
  /// class MyApp extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       navigatorKey: router.navigatorKey,
  ///     );
  ///   }
  /// }
  /// ```
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 导航控制器
  ///
  /// ```dart
  /// router.navigator.pushNamed('/home');
  /// ```
  NavigatorState get navigator => navigatorKey.currentState;

  Route<T> _findRoute<T>(String routeName, Object arguments) {
    assert(routeName != null);
    final RouteSettings settings = RouteSettings(
      name: routeName,
      isInitialRoute: history.isEmpty,
      arguments: arguments,
    );
    return onGenerateRoute<T>(settings);
  }

  /// history is: [/users /home]
  ///
  /// pushNamed('/new')
  ///
  /// history is: [/users /home /new]
  Future<T> pushNamed<T extends Object>(
    String routeName, {
    Object arguments,
    bool allowNull = true,
  }) {
    assert(routeName != null);
    if (allowNull) {
      Route<T> route = _findRoute(routeName, arguments);
      return route != null ? navigator.push<T>(route) : Future.value(null);
    } else {
      return navigator.pushNamed(routeName, arguments: arguments);
    }
  }

  /// history is: [/users /home]
  ///
  /// pushReplacementNamed('/new')
  ///
  /// history is: [/users /new]
  Future<T> pushReplacementNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Object arguments,
    bool allowNull = true,
  }) {
    if (allowNull) {
      Route<T> route = _findRoute(routeName, arguments);
      return route != null
          ? navigator.pushReplacement<T, TO>(
              route,
              result: result,
            )
          : Future.value(null);
    } else {
      return navigator.pushReplacementNamed(
        routeName,
        result: result,
        arguments: arguments,
      );
    }
  }

  /// history is: [/users /home]
  ///
  /// popAndPushNamed('/new')
  ///
  /// history is: [/users /new]
  Future<T> popAndPushNamed<T extends Object, TO extends Object>(
    String routeName, {
    TO result,
    Object arguments,
    bool allowNull = true,
  }) {
    if (allowNull) {
      Route<T> route = _findRoute(routeName, arguments);
      if (route != null) {
        pop<TO>(result);
        return navigator.pushNamed<T>(routeName, arguments: arguments);
      } else {
        return Future.value(null);
      }
    } else {
      return navigator.popAndPushNamed(
        routeName,
        result: result,
        arguments: arguments,
      );
    }
  }

  /// Example 1:
  ///
  /// history is: [/users /home /new]
  ///
  /// pushNamedAndRemoveUntil('/users', (_) => false)
  ///
  /// history is: [/users]
  ///
  ///
  /// Example 2:
  ///
  /// history is: [/users /home /new]
  ///
  /// pushNamedAndRemoveUntil('/users', ModalRoute.withName('/home'))
  ///
  /// history is: [/users /home /users]
  Future<T> pushNamedAndRemoveUntil<T extends Object>(
    String newRouteName,
    RoutePredicate predicate, {
    Object arguments,
    bool allowNull = true,
  }) {
    if (allowNull) {
      Route<T> route = _findRoute(newRouteName, arguments);
      return route != null
          ? navigator.pushAndRemoveUntil<T>(route, predicate)
          : Future.value(null);
    } else {
      return navigator.pushNamedAndRemoveUntil(
        newRouteName,
        predicate,
        arguments: arguments,
      );
    }
  }

  Future<T> Function<T extends Object>(Route<T> route) get push =>
      navigator.push;

  Future<T> Function<T extends Object, TO extends Object>(Route<T> newRoute,
      {TO result}) get pushReplacement => navigator.pushReplacement;

  Future<T> Function<T extends Object>(
          Route<T> newRoute, bool Function(Route<dynamic>) predicate)
      get pushAndRemoveUntil => navigator.pushAndRemoveUntil;

  void Function<T extends Object>({Route<dynamic> oldRoute, Route<T> newRoute})
      get replace => navigator.replace;

  void Function<T extends Object>(
      {Route<dynamic> anchorRoute,
      Route<T> newRoute}) get replaceRouteBelow => navigator.replaceRouteBelow;

  bool Function() get canPop => navigator.canPop;

  Future<bool> Function<T extends Object>([T result]) get maybePop =>
      navigator.maybePop;

  bool Function<T extends Object>([T result]) get pop => navigator.pop;

  void Function(bool Function(Route<dynamic>) predicate) get popUntil =>
      navigator.popUntil;

  void Function(Route<dynamic> route) get removeRoute => navigator.removeRoute;

  void Function(Route<dynamic> anchorRoute) get removeRouteBelow =>
      navigator.removeRouteBelow;
}
