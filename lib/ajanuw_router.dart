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
  AjanuwRouter({
    this.baseHref = '/',
  });

  final String baseHref;

  /// TODO: 所有路由将被打平放在这里面
  final Map<String, AjanuwRouting> routers = {};

  /// 动态路由
  ///
  /// /user/:id
  static Map<String, AjanuwRouting> _dynamicRouters = {};

  /// 重定向路由
  static Map<String, AjanuwRouting> _redirectTorouters = {};

  /// 普通路由
  static Map<String, AjanuwRouting> _routers = {};

  /// 404页面
  static AjanuwRouting _notFound;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 导航控制器
  NavigatorState get navigator => navigatorKey.currentState;

  /// 检查是否为动态路由
  static bool _hasDynamicRouting(String routeName) {
    List<String> routeNameSplit = routeName.split('/');
    for (var item in routeNameSplit) {
      if (item.startsWith(':')) return true;
    }
    return false;
  }

  static bool _matchPath(
    String routeName,
    MapEntry<String, AjanuwRouting> other,
  ) {
    final Pattern pattern = '/';
    List<String> routeNameSplit = routeName.split(pattern);
    List<String> otherRouteNameSplit = other.key.split(pattern);

    final bool equalRouteLength =
        routeNameSplit.length == otherRouteNameSplit.length;
    return equalRouteLength && other.value.exp.hasMatch(routeName);
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

  /// 为路由的children绑定权限
  // static bool _hasCanActivateChild(AjanuwRouting routing) {
  //   if (routing?.canActivateChild?.isNotEmpty ?? false) {
  //     for (CanActivate t in routing?.canActivateChild) {
  //       if (t(routing) == false) {
  //         // 返回null会造成错误，但是能停止跳转
  //         return false;
  //       }
  //     }
  //     return true;
  //   }
  //   return true;
  // }

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

  /// 注册普通/动态路由
  void define({
    String path,
    AjanuwRouting routing,
  }) {
    if (_hasDynamicRouting(path)) {
      _dynamicRouters[path] = _createDynamicRouting(path, routing);
    } else {
      _routers[path] = routing;
    }
  }

  /// 创建一个动态路由
  ///
  /// 如: /user/:id
  AjanuwRouting _createDynamicRouting(
    String name,
    AjanuwRouting routing,
  ) {
    List<String> routeNameSplit = name.split('/');

    String exp = '';
    List<DynamicRoutingParam> params = [];

    for (var i = 0; i < routeNameSplit.length; i++) {
      String item = routeNameSplit[i];
      String expItem = '\/' + item;
      if (item.startsWith(':')) {
        expItem = '/([^/]+)';
        String name = item;
        int index = i;
        params.add(DynamicRoutingParam(name, index));
      }
      exp += expItem;
    }
    RegExp parseExp = RegExp("${exp.replaceFirst('/', '')}", dotAll: true);

    return routing.copyWith(
      exp: parseExp,
      params: params,
    );
  }

  /// 注册重定向路由
  void redirectTo({
    String path,
    AjanuwRouting routing,
  }) {
    _redirectTorouters[path] = routing;
  }

  /// 注册404页面
  void notFound(
    AjanuwRouting routing,
  ) {
    _notFound = routing;
  }

  /// 初始化应用程序的导航
  AjanuwRouteFactory forRoot(List<AjanuwRoute> configRoutes,
      [String parentPath = '/']) {
    for (var i = 0; i < configRoutes.length; i++) {
      final AjanuwRoute route = configRoutes[i];

      // 匹配 404
      if (route.isNotFoundRoute) {
        notFound(AjanuwRouting(route: route));
        continue;
      }

      // 重定向路由
      if (route.isRedirect) {
        redirectTo(
          path: p.join(parentPath, route.path),
          routing: AjanuwRouting(route: route),
        );
        continue;
      }

      // 包含了子路由
      if (route.children != null) {
        for (AjanuwRoute cr in route.children) {
          String parent = p.join(parentPath, route.path);
          String path = p.join(parent, cr.path);
          define(
            path: path,
            routing: AjanuwRouting(
              // 权限的继承，当父路由被添加了访问权限时,
              // 子路由也会被绑定
              route: cr.canActivate == null
                  ? cr.copyWith(
                      canActivate: route.canActivate,
                    )
                  : cr,
              parent: parent,
            ),
          );
          if (cr.children != null) {
            forRoot(cr.children, path);
          }
        }
      }
      // TODO: 这种情况怎么办
      // AjanuwRoute( path: '', builder: (c, s) => home,),
      //
      // 普通路由
      if (route.builder != null) {
        define(
          path: p.join(parentPath, route.path),
          routing: AjanuwRouting(route: route),
        );
      }
    }
    return onGenerateRoute;
  }

  /// [navigtor.pop()]并不会触发[onGenerateRoute]
  AjanuwRouteFactory onGenerateRoute = (RouteSettings settings) {
    settings = AjanuwRouteSettings.extend(settings: settings);
    // 普通路由
    for (var item in _routers.entries) {
      if (settings.name == item.key) {
        AjanuwRouting r = item.value.copyWith(settings: settings);
        return _hasCanActivate(r) ? r.builder(settings) : null;
      }
    }

    // 动态路由
    for (var item in _dynamicRouters.entries) {
      if (_matchPath(settings.name, item)) {
        var paramMap = _snapshot(settings.name, item.value);
        settings = AjanuwRouteSettings.extend(
          paramMap: paramMap,
          settings: settings,
        );
        var r = item.value.copyWith(settings: settings);
        return _hasCanActivate(r) ? r.builder(settings) : null;
      }
    }

    // 重定向路由
    for (var item in _redirectTorouters.entries) {
      if (settings.name == item.key) {
        var r = item.value.copyWith(settings: settings);
        String redirectToName = _redirectTorouters[item.key].route.redirectTo;
        return _hasCanActivate(r)
            ? _routers[redirectToName].builder(r.settings)
            : null;
      }
    }

    // 当所有路由不匹配时，返回404
    return _routers[_notFound.route.redirectTo].builder(
      settings.copyWith(
        name: _notFound.route.redirectTo,
      ),
    );
  };
}
