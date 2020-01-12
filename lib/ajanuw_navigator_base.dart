import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ajanuw_route.dart';
import 'ajanuw_route_observer.dart';

abstract class AjanuwNavigatorBase {
  Route<T> onGenerateRoute<T>(RouteSettings settings, [bool view]);
  RouteFactory forRoot(List<AjanuwRoute> configRoutes);
  List<Route<dynamic>> history = [];
  Route<dynamic> get lastHistory => history.last;
  bool printHistory = false;
  bool more = false;
  final _routeListener = StreamController<AjanuwRouteObserverData>();
  get _routeListener$ => _routeListener.stream.asBroadcastStream();

  NavigatorObserver get navigatorObserver =>
      AjanuwRouteObserver(_routeListener);

  AjanuwNavigatorBase() {
    _routeListener$.listen((AjanuwRouteObserverData observer) {
      switch (observer.type) {
        case AjanuwRouteObserverType.didPush:
          history.add(observer.to);
          break;
        case AjanuwRouteObserverType.didReplace:
          final Route<dynamic> oldRoute = history.last;
          final int index = history.length - 1;
          assert(index >= 0);
          assert(history.indexOf(oldRoute) == index);
          history[index] = observer.to;
          break;
        case AjanuwRouteObserverType.didPop:
          if (history.length > 1) {
            history.removeLast();
          }
          break;
        case AjanuwRouteObserverType.didRemove:
          Route<dynamic> to = observer.to;
          if (to != null) {
            if (to.settings.name != history.last.settings.name) {
              // print(history.last.settings.name);
              history.removeLast();
            }
          } else {
            // pushNamedAndRemoveUntil('/', (_) => false)
            // 当返回false的时候to就为null

            // 先push在remove，跳过最后一个
            int _index = history.length - 2;
            if (_index >= 0) {
              history.removeAt(_index);
            }
          }
          break;
        default:
      }
      if (printHistory) {
        if (more) {
          print(history);
        } else {
          print(history.map((r) => r.settings.name));
        }
      }
    });
  }

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

  Route<T> _findRoute<T>(String routeName, Object arguments, [view = false]) {
    assert(routeName != null);
    final RouteSettings settings = RouteSettings(
      name: routeName,
      isInitialRoute: history.isEmpty,
      arguments: arguments,
    );
    return onGenerateRoute<T>(settings, view);
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

    /// 如果使用了这个参数，则不会被加入history
    bool view = false,
  }) {
    assert(routeName != null);
    if (view) {
      _findRoute(routeName, arguments, view);
      return Future.value(null);
    } else {
      if (allowNull) {
        Route<T> route = _findRoute(routeName, arguments);
        return route != null ? navigator.push<T>(route) : Future.value(null);
      } else {
        return navigator.pushNamed(routeName, arguments: arguments);
      }
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
  /// history is: [/users]
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
  /// history is: [/users /home]
  ///
  /// pushNamedAndRemoveUntil('/new', (_) => false)
  ///
  /// history is: [/new]
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

  dispose() {
    _routeListener.close();
  }
}
