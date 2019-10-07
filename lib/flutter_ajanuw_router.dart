library flutter_ajanuw_router;

import 'package:flutter/material.dart';

import 'util/path.dart';
import 'util/replace_first.dart';
import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'ajanuw_routing.dart';

typedef AjanuwRouteFactory = Route<dynamic> Function(
    AjanuwRouteSettings settings);
typedef CanActivate = bool Function(AjanuwRouting routing);
typedef CanActivateChild = bool Function(AjanuwRouting routing);

class AjanuwRouter {
  static final String baseHref = '/';
  static String ajanuwInitialRoute;

  /// 所有路由将被打平放在这里面，如果需要可以获取
  /// ```dart
  /// print(AjanuwRouter.routers);
  /// ```
  static final Map<String, AjanuwRouting> routers = {};

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

  /// 将跳转路径[settings.name]从[routers]里面匹配出对应的[Routing]
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

  /// TODO: 如何解决拦截时产生的错误
  /// TODO: 如何做异步拦截器
  /// 访问该路由，是否有权限
  /// 设置[onUnknownRoute]将会使拦截时重定向失败
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

  void _forRoot(List<AjanuwRoute> configRoutes, String parentPath) {
    for (var i = 0; i < configRoutes.length; i++) {
      final AjanuwRoute route = configRoutes[i];

      // 重定向路由
      if (route.type == AjanuwRouteType.redirect) {
        String path = p.join(parentPath, route.path);
        routers[path] = AjanuwRouting(
          path: path,
          route: route,
        );
        continue;
      }

      // 包含了子路由
      if (route.children != null) {
        for (AjanuwRoute cr in route.children) {
          String parent = p.join(parentPath, route.path);
          String path = p.join(parent, cr.path);

          AjanuwRoute.isDynamicRouting(path);
          var routing = AjanuwRouting(
            path: path,
            // 权限继承，当父路由被添加了访问权限时,
            // 子路由也会被绑定
            route: cr.canActivate == null
                ? cr.copyWith(canActivate: route.canActivate)
                : cr,
            parent: parent,
          );
          routers[path] = routing;
          if (cr.children != null) {
            _forRoot(cr.children, path);
          }
        }
      }

      // 普通路由和动态路由
      String path = p.join(parentPath, route.path);
      routers[path] = AjanuwRouting(
        path: path,
        route: route,
      );
    }
  }

  /// 初始化应用程序的导航
  AjanuwRouteFactory forRoot(
    List<AjanuwRoute> configRoutes, {
    @required String initialRoute,
  }) {
    ajanuwInitialRoute = initialRoute;
    _forRoot(configRoutes, baseHref);
    return onGenerateRoute;
  }

  static bool _firstNavigotor = true;

  /// [navigtor.pop()]并不会触发[onGenerateRoute]
  /// 在浏览器上很诡异
  /// 如访问 'http://localhost:57313/#/www/data/aaa'
  /// /
  /// /www
  /// /www/data
  /// /www/data/aaa
  /// 依次推入
  static AjanuwRouteFactory onGenerateRoute = (RouteSettings settings) {
    String routeName = settings.name;

    // [AjanuwRouteSettings]扩展了[RouteSettings]
    // 为了能够在[settings]加上动态路由的值
    final ajanuwRouteSettings = AjanuwRouteSettings.extend(settings: settings);

    // 为什么要做这个判断？
    // 因为Flutter在程序启动会自动发送一个为'/'的路由进来
    // 如果用户设置了'/'route则会发生匹配，页面入栈: [ / ]
    // 但是当用户的[initialRoute]设置为，如'/login'时，初始化页面应该是'login'，但是此时的栈是[/, login]
    // 所以在第一次检测Flutetr自动推进来的'/'是否为用户设置的[initialRoute]
    // 如果是，则继续导航，不是则跳过
    if (_firstNavigotor) {
      if (routeName != ajanuwInitialRoute) {
        _firstNavigotor = false;
        return null;
      }
      _firstNavigotor = false;
    }

    // 使用[settings]在[routers]里面匹配到对应的路由
    AjanuwRouting routing = _matchPath(settings.name) ??
        _matchPath(p.join(baseHref, AjanuwRoute.notFoundRouteName));

    routing = routing.copyWith(
      url: settings.name,
      settings: ajanuwRouteSettings,
    );

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
      if (p.isRelative(redirectName)) {
        redirectName = p.join(baseHref, redirectName);
      }
      return onGenerateRoute(ajanuwRouteSettings.copyWith(
        name: redirectName,
      ));
    }

    return routing.builder(routing.settings);
  };
}
