library flutter_ajanuw_router;

import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/path.dart';

import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'ajanuw_routing.dart';

typedef AjanuwRouteFactory = Route<dynamic> Function(
    AjanuwRouteSettings settings);
typedef CanActivate = bool Function(AjanuwRouting routing);
typedef CanActivateChild = bool Function(AjanuwRouting routing);

class AjanuwRouter {
  static final String baseHref = '/';

  /// 所有路由将被打平放在这里面
  static final Map<String, AjanuwRouting> routers = {};

  /// 普通路由
  // static Map<String, AjanuwRouting> _routers = {};

  /// 404页面
  // static AjanuwRouting _notFound;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 导航控制器
  NavigatorState get navigator => navigatorKey.currentState;

  static AjanuwRouting _matchPath(
    AjanuwRouteSettings settings,
  ) {
    String routeName = settings.name;
    // /home -> home
    if (routeName.startsWith('/')) {
      routeName = routeName.replaceFirst('/', '');
    }

    // 如果能映射，直接返回
    if (routers.containsKey(routeName)) {
      return routers[routeName];
    }

    // 找不到估计就是动态路由
    // users/3 -> users/:id
    final Pattern pattern = '/';
    List<String> routeNameSplit = routeName.split(pattern);
    final List<AjanuwRouting> dynamicRouters = routers.values.where((routing) {
      return routing.type == AjanuwRouteType.dynamic;
    }).toList();
    for (var routing in dynamicRouters) {
      List<String> dynamicRouteNameSplit = routing.path.split(pattern);
      final bool equalRouteLength =
          routeNameSplit.length == dynamicRouteNameSplit.length;
      if (equalRouteLength && routing.exp.hasMatch(routeName)) {
        return routing;
      }
    }

    // 什么都没找到，返回404
    print('什么都没找到，返回404');
    return routers[AjanuwRoute.notFoundRouteName];
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
  static Map<String, String> _snapshot(String routeName, AjanuwRouting dr) {
    Map<String, String> paramMap = {};
    routeName.replaceAllMapped(dr.exp, (Match m) {
      for (int i = 0; i < m.groupCount; i++) {
        DynamicRoutingParam item = dr.params[i];
        String key = item.name.replaceFirst(':', '');
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
  AjanuwRouteFactory forRoot(List<AjanuwRoute> configRoutes) {
    _forRoot(configRoutes);
    return onGenerateRoute;
  }

  /// [navigtor.pop()]并不会触发[onGenerateRoute]
  static AjanuwRouteFactory onGenerateRoute = (RouteSettings settings) {
    /// [settings.name]在使用[navigator.pushNamed(name)]时[settings.name = name]
    /// 扩展[RouteSettings]，为了能够在[settings]加上动态路由的值
    final ajanuwRouteSettings = AjanuwRouteSettings.extend(settings: settings);

    /// 使用[settings]在[routers]里卖匹配到对应的路由
    AjanuwRouting routing = _matchPath(ajanuwRouteSettings);

    if (routing.type == AjanuwRouteType.redirect) {
      String redirectName = routing.route.redirectTo.replaceFirst('/', '');
      if (_hasCanActivate(routing)) {
        return onGenerateRoute(AjanuwRouteSettings(
          name: p.join(baseHref, redirectName),
          isInitialRoute: ajanuwRouteSettings.isInitialRoute,
          arguments: ajanuwRouteSettings.arguments,
        ));
      }
      return null;
    }

    if (routing.type == AjanuwRouteType.dynamic) {
      var paramMap = _snapshot(ajanuwRouteSettings.name, routing);

      var r = routing.copyWith(
        settings: ajanuwRouteSettings.copyWith(paramMap: paramMap),
      );
      return _hasCanActivate(r) ? r.builder(ajanuwRouteSettings) : null;
    }

    return _hasCanActivate(routing)
        ? routing.builder(ajanuwRouteSettings)
        : null;
  };
}
