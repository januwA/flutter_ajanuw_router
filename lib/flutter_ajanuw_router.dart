library flutter_ajanuw_router;

import 'dart:async';

import 'package:flutter/material.dart';

import 'util/path.dart';
import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'ajanuw_routing.dart';
import 'util/remove_first_string.dart';

typedef AjanuwRouteFactory = Route<dynamic> Function(
    AjanuwRouteSettings settings);

typedef CanActivate = bool Function(AjanuwRouting routing);

class AjanuwRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final StreamController<AjanuwRouteObserverData> _listenner;
  AjanuwRouteObserver(this._listenner);

  /// router init
  /// pushNamed
  /// pushNamedAndRemoveUntil
  /// popAndPushNamed
  /// 向history推送线路
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didPush,
      from: previousRoute,
      to: route,
    ));
  }

  /// pushReplacementNamed
  /// 将history最后一个route替换为新route
  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didReplace,
      from: oldRoute,
      to: newRoute,
    ));
  }

  /// pop
  /// popAndPushNamed
  /// popUntil
  /// 移除最后一条线路
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didPop,
      from: route,
      to: previousRoute,
    ));
  }

  @override
  void didRemove(Route from, Route to) {
    super.didRemove(from, to);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didRemove,
      from: from,
      to: to,
    ));
  }
}

enum AjanuwRouteObserverType {
  didPush,
  didReplace,
  didPop,
  didRemove,
}

class AjanuwRouteObserverData {
  final AjanuwRouteObserverType type;
  final Route<dynamic> from;
  final Route<dynamic> to;

  AjanuwRouteObserverData({this.type, this.from, this.to});
}

class AjanuwRouter {
  AjanuwRouter() {
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
          if (history.isNotEmpty) {
            if (to != null) {
              if (to.settings.name != history.last.settings.name) {
                history.removeLast();
              }
            } else {
              history.removeLast();
            }
          }
          break;
        default:
      }
    });
  }

  static final _routeListener = StreamController<AjanuwRouteObserverData>();
  static Stream<AjanuwRouteObserverData> get _routeListener$ =>
      _routeListener.stream.asBroadcastStream();
  final NavigatorObserver navigatorObserver =
      AjanuwRouteObserver(_routeListener);
  static final String baseHref = '/';

  /// 所有路由将被打平放在这里面，如果需要可以查看
  /// ```dart
  /// for (var item in AjanuwRouter.routers.entries) {
  ///   print(item.key);
  /// }
  /// ```
  static final Map<String, AjanuwRouting> routers = {};
  static List<Route<dynamic>> history = [];

  /// 必须在[MaterialApp]中设置[navigatorKey]，才能使用[router.navigator]
  ///
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
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 导航控制器
  ///
  /// ```dart
  /// router.navigator.pushNamed('/home');
  /// ```
  NavigatorState get navigator => navigatorKey.currentState;

  /// 匹配路径
  static AjanuwRouting _matchPath(String routeName) {
    // 如果能映射，直接返回
    if (routers.containsKey(routeName)) {
      return routers[routeName];
    }

    // 找不到估计就是动态路由
    // 拉出所有动态路由
    final List<AjanuwRouting> dynamicRouters = _getAllDynamicRoutings();
    for (var routing in dynamicRouters) {
      if (_matchDynamicRoute(routeName, routing)) {
        return routing;
      }
    }
    return null;
  }

  /// 获取所有[AjanuwRouteType.dynamic]的routing
  static List<AjanuwRouting> _getAllDynamicRoutings() {
    return routers.values
        .where((routing) => routing.type == AjanuwRouteType.dynamic)
        .toList();
  }

  /// /users/2 匹配 /users/:id
  static bool _matchDynamicRoute(
      String routeName, AjanuwRouting dynamicRouting) {
    final Pattern pattern = '/';
    List<String> routeNameSplit = routeName.split(pattern);
    List<String> dynamicRouteNameSplit = dynamicRouting.path.split(pattern);
    final bool equalRouteLength =
        routeNameSplit.length == dynamicRouteNameSplit.length;
    return equalRouteLength &&
        dynamicRouting.exp.hasMatch(routeNameSplit.join(pattern));
  }

  /// 访问该路由，是否有权限
  static bool _hasCanActivate(AjanuwRouting routing) {
    if (routing.route?.canActivate?.isNotEmpty ?? false) {
      for (CanActivate t in routing.route?.canActivate) {
        if (t(routing) == false) {
          // 返回null会造成错误，但是能停止跳转
          return false;
        }
      }
      return true;
    }
    return true;
  }

  /// 解析出动态路由的参数
  static Map<String, String> _snapshot(
      String routeName, AjanuwRouting dynamicRouting) {
    Map<String, String> paramMap = {};
    routeName.replaceAllMapped(dynamicRouting.exp, (Match m) {
      for (int i = 0; i < m.groupCount; i++) {
        DynamicRoutingParam item = dynamicRouting.params[i];
        String key = removeFirstString(item.name, ':');
        String value = m[i + 1];
        paramMap[key] = value;
      }
      return '';
    });
    return paramMap;
  }

  void _forRoot(List<AjanuwRoute> routes, String parentPath) {
    for (AjanuwRoute route in routes) {
      // 重定向路由
      if (route.type == AjanuwRouteType.redirect) {
        String path = p.join(parentPath, route.path);
        routers[path] = AjanuwRouting(path: path, route: route);
        continue;
      }

      // 包含了子路由
      if (route.children != null) {
        for (AjanuwRoute child in route.children) {
          String parent = p.join(parentPath, route.path);
          String path = p.join(parent, child.path);

          var routing = AjanuwRouting(
            path: path,
            // 权限继承，当父路由被添加了访问权限时,
            // 子路由也会被绑定
            route: child.canActivate == null
                ? child.copyWith(canActivate: route.canActivate)
                : child,
            parent: parent,
          );
          routers[path] = routing;
          if (child.children != null) {
            _forRoot(child.children, path);
          }
        }
      }

      // 普通路由和动态路由
      // 跳过没有注册builder的路由
      if (route.builder != null) {
        String path = p.join(parentPath, route.path);
        routers[path] = AjanuwRouting(
          path: path,
          route: route,
          parent: parentPath,
        );
      }
    }
  }

  /// 初始化应用程序的导航
  AjanuwRouteFactory forRoot(List<AjanuwRoute> configRoutes) {
    history.clear();
    _forRoot(configRoutes, '');
    return onGenerateRoute;
  }

  /// [navigtor.pop()]并不会触发[onGenerateRoute]
  /// 在浏览器上很诡异
  /// 如访问 'http://localhost:57313/#/www/data/aaa'
  /// /
  /// /www
  /// /www/data
  /// /www/data/aaa
  /// 依次推入
  static AjanuwRouteFactory onGenerateRoute = (RouteSettings settings) {
    AjanuwRouteSettings ajanuwRouteSettings =
        AjanuwRouteSettings.extend(settings: settings);

    String routeName = ajanuwRouteSettings.name;

    // push('/home'); 绝对路径
    // push('home'); 相对路径
    // push('../../home'); 相对路径
    if (p.isRelative(routeName) &&
        history.isNotEmpty &&
        history?.last != null) {
      routeName = p.normalize(
        p.join(
          removeFirstString(
            history.last.settings.name,
            AjanuwRouter.baseHref,
          ),
          routeName,
        ),
      );
    } else {
      routeName = removeFirstString(routeName);
    }

    // print('routeName: $routeName');

    ajanuwRouteSettings = ajanuwRouteSettings.copyWith(name: routeName);

    // 使用[settings]在[routers]里面匹配到对应的路由
    AjanuwRouting routing =
        _matchPath(routeName) ?? _matchPath(AjanuwRoute.notFoundRouteName);

    //  没有注册[**]路由
    if (routing == null) {
      print(
          'AjanwuRouter Error: Did not find the registered [**] route, return to the blank page');
      return MaterialPageRoute(builder: (_) => Scaffold());
    }
    routing = routing.copyWith(settings: ajanuwRouteSettings);

    // 如果是动态路由，先解析出参数
    if (routing.type == AjanuwRouteType.dynamic) {
      var paramMap = _snapshot(routeName, routing);
      routing = routing.copyWith(
        settings: ajanuwRouteSettings.copyWith(paramMap: paramMap),
      );
    }

    // 拦截器
    if (!_hasCanActivate(routing)) {
      return null;
    }

    if (routing.type == AjanuwRouteType.redirect) {
      String redirectName = routing.route.redirectTo;
      return onGenerateRoute(ajanuwRouteSettings.copyWith(name: redirectName));
    }

    Route<dynamic> _route = routing.builder(routing.settings);
    return _route;
  };

  dispose() {
    _routeListener.close();
  }
}
