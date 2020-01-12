library flutter_ajanuw_router;

import 'dart:async';

import 'package:flutter/material.dart';

import 'ajanuw_navigator_base.dart';
import 'ajanuw_route_observer.dart';
import 'util/path.dart';
import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'ajanuw_routing.dart';
import 'util/remove_first_string.dart';

typedef AjanuwRouteFactory = Route<dynamic> Function(
    AjanuwRouteSettings settings);

typedef CanActivate = bool Function(AjanuwRouting routing);

class AjanuwRoutings {
  /// All routes will be laid flat inside, you can view if needed
  /// ```dart
  /// for (var item in AjanuwRoutings.routers.entries) {
  ///   print(item.key);
  /// }
  /// ```
  static final Map<String, AjanuwRouting> routers = {};
  static void add(String name, AjanuwRouting value) => routers[name] = value;
  static bool has(String name) => routers.containsKey(name);
  static AjanuwRouting get(String name) => routers[name];

  /// 所有动态路由
  static List<AjanuwRouting> get dynamicRoutings =>
      routers.values.where((routing) => routing.isDynamic).toList();

  /// 找不到估计就是动态路由
  /// 拉出所有动态路由
  static AjanuwRouting findDynamic(String name) {
    return dynamicRoutings.firstWhere(
        (dynamicRouting) => _matchDynamicRoute(name, dynamicRouting),
        orElse: () => null);
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
}

class AjanuwRouter extends AjanuwNavigatorBase {
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
      // print(history.map((r) => r.settings.name));
    });
  }

  final _routeListener = StreamController<AjanuwRouteObserverData>();
  Stream<AjanuwRouteObserverData> get _routeListener$ =>
      _routeListener.stream.asBroadcastStream();
  NavigatorObserver get navigatorObserver =>
      AjanuwRouteObserver(_routeListener);

  /// 匹配路径
  static AjanuwRouting _matchPath(String routeName) {
    // 如果能映射，直接返回
    if (AjanuwRoutings.has(routeName)) {
      return AjanuwRoutings.get(routeName);
    }
    return AjanuwRoutings.findDynamic(routeName);
  }

  /// 访问该路由，是否有权限
  static bool _hasCanActivate(AjanuwRouting routing) {
    if (routing.route.canActivate == null || routing.route.canActivate.isEmpty)
      return true;
    for (CanActivate t in routing.route.canActivate) {
      if (!t(routing)) return false;
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
      if (route.isRedirect) {
        String path = p.join(parentPath, route.path);
        AjanuwRoutings.add(path, AjanuwRouting(path: path, route: route));
        continue;
      }

      // 包含了子路由
      if (route.hasChildren) {
        for (AjanuwRoute childRoute in route.children) {
          String parent = p.join(parentPath, route.path);
          String path = p.join(parent, childRoute.path);

          var routing = AjanuwRouting(
            path: path,
            // 权限继承，当父路由被添加了访问权限时,
            // 子路由也会被绑定
            route: childRoute.canActivate == null
                ? childRoute.copyWith(canActivate: route.canActivate)
                : childRoute,
            parent: parent,
          );
          AjanuwRoutings.add(path, routing);
          if (childRoute.hasChildren) {
            _forRoot(childRoute.children, path);
          }
        }
      }

      // 普通路由和动态路由
      // 跳过没有注册builder的路由
      if (route.hasBuilder) {
        String path = p.join(parentPath, route.path);
        AjanuwRoutings.add(
            path,
            AjanuwRouting(
              path: path,
              route: route,
              parent: parentPath,
            ));
      }
    }
  }

  /// 初始化应用程序的导航
  RouteFactory forRoot(List<AjanuwRoute> configRoutes) {
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
  @override
  Route<T> onGenerateRoute<T>(RouteSettings settings) {
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
            "/",
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
    if (routing.isDynamic) {
      routing = routing.copyWith(
        settings: ajanuwRouteSettings.copyWith(
            paramMap: _snapshot(routeName, routing)),
      );
    }

    // 拦截器
    // 返回null会造成错误，但是能停止跳转
    if (!_hasCanActivate(routing)) {
      return null;
    }

    if (routing.isRedirect) {
      return onGenerateRoute(
          ajanuwRouteSettings.copyWith(name: routing.route.redirectTo));
    }

    return routing.builder<T>();
  }

  dispose() {
    _routeListener.close();
  }
}
