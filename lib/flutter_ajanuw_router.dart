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
  static String ajanuwRouterBaseHref;

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
  ///       onGenerateRoute: router.forRoot(routes),
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
  static AjanuwRouting _matchPath(
    RouteSettings settings,
  ) {
    // /home -> home
    String routeName = removeFirstString(settings.name);

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

    // 什么都没找到，返回404
    return routers[AjanuwRoute.notFoundRouteName];
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
  /// TODO: 设置[onUnknownRoute]将会使拦截时重定向失败
  /// TODO: 如何做异步拦截器
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

  void _forRoot(List<AjanuwRoute> configRoutes, [String parentPath = '']) {
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

      // 普通路由
      if (route.type == AjanuwRouteType.normal) {
        String path = p.join(parentPath, route.path);
        routers[path] = AjanuwRouting(
          path: path,
          route: route,
        );
      }
    }
  }

  /// 初始化应用程序的导航
  AjanuwRouteFactory forRoot(
    List<AjanuwRoute> configRoutes, {
    String baseHref = '/',
  }) {
    ajanuwRouterBaseHref = baseHref;
    _forRoot(configRoutes);
    return onGenerateRoute;
  }

  /// [navigtor.pop()]并不会触发[onGenerateRoute]
  static AjanuwRouteFactory onGenerateRoute = (RouteSettings settings) {
    // [settings.name]在使用[navigator.pushNamed(name)]时[settings.name = name]
    String routeName = settings.name;
    print(routeName);

    // 使用[settings]在[routers]里面匹配到对应的路由
    AjanuwRouting routing = _matchPath(settings);

    /// 这个url，最终将会在浏览器上表现出来
    String url;
    if (p.isWithin(ajanuwRouterBaseHref, routeName)) {
      // /www  /www/home
      url = p.join(ajanuwRouterBaseHref, settings.name);
    } else if (p.isAbsolute(settings.name)) {
      // /www  /home
      url = ajanuwRouterBaseHref + settings.name;
    } else {
      // /www  home
      url = p.join(ajanuwRouterBaseHref, settings.name);
    }

    routing = routing.copyWith(url: url);

    // [AjanuwRouteSettings]扩展了[RouteSettings]
    // 为了能够在[settings]加上动态路由的值
    final ajanuwRouteSettings = AjanuwRouteSettings.extend(settings: settings);

    if (routing.type == AjanuwRouteType.redirect) {
      String redirectName = removeFirstString(routing.route.redirectTo);
      if (_hasCanActivate(routing)) {
        return onGenerateRoute(AjanuwRouteSettings(
          name: redirectName,
          isInitialRoute: ajanuwRouteSettings.isInitialRoute,
          arguments: ajanuwRouteSettings.arguments,
        ));
      }
      return null;
    }

    if (routing.type == AjanuwRouteType.dynamic) {
      var paramMap = _snapshot(routeName, routing);

      var r = routing.copyWith(
        settings: ajanuwRouteSettings.copyWith(
          name: routing.url,
          paramMap: paramMap,
        ),
      );
      return _hasCanActivate(r) ? r.builder(ajanuwRouteSettings) : null;
    }

    return _hasCanActivate(routing)
        ? routing.builder(ajanuwRouteSettings)
        : null;
  };
}
