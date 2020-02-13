library flutter_ajanuw_router;

import 'package:flutter/material.dart';

import 'ajanuw_navigator_base.dart';
import 'util/path.dart';
import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'ajanuw_routing.dart';
import 'util/remove_first_string.dart';

typedef CanActivate = bool Function(AjanuwRouting routing);

class AjanuwRouter extends AjanuwNavigatorBase {
  final AjanuwRoutings routings = AjanuwRoutings();

  AjanuwRouter({
    bool printHistory = false,
    bool more = false,
  }) : super(
          printHistory: printHistory,
          more: more,
        );

  /// 访问该路由，是否有权限
  bool _hasCanActivate(AjanuwRouting routing) {
    if (routing.route.canActivate == null || routing.route.canActivate.isEmpty)
      return true;
    for (CanActivate t in routing.route.canActivate) {
      if (!t(routing)) return false;
    }
    return true;
  }

  /// 解析出动态路由的参数
  Map<String, String> _snapshot(
    String routeName,
    AjanuwRouting dynamicRouting,
  ) {
    Map<String, String> paramMap = {};
    routeName.replaceAllMapped(dynamicRouting.exp, (Match m) {
      for (int i = 0; i < m.groupCount; i++) {
        DynamicRoutingParam item = dynamicRouting.params[i];
        String key = removeFirstString(item.name ?? '', ':');
        String value = m[i + 1];
        paramMap[key] = value;
      }
      return '';
    });
    return paramMap;
  }

  void _forRoot(Iterable<AjanuwRoute> routes, String parentPath) {
    for (AjanuwRoute route in routes) {
      String _parentPath = urlPath.join(parentPath, route.path);
      route.toRouting(routings, parentPath);
      // if (route.isRedirect || route.hasBuilder) {
      //   routings.add(AjanuwRouting(route: route, parent: parentPath));
      // }

      // 包含了子路由
      if (route.hasChildren) {
        _forRoot(
          route.children.map((childRoute) {
            return childRoute.canActivate == null
                ? childRoute.copyWith(canActivate: route.canActivate)
                : childRoute;
          }),
          _parentPath,
        );
      }
    }
  }

  /// 初始化应用程序的导航
  @override
  RouteFactory forRoot(Iterable<AjanuwRoute> configRoutes) {
    _forRoot(configRoutes, '');
    return onGenerateRoute;
  }

  /// [navigtor.pop]并不会触发[onGenerateRoute]
  ///
  /// 在浏览器上很诡异
  ///
  /// 如访问 http://localhost:57313/#/www/data/aaa
  ///
  /// /
  ///
  /// /www
  ///
  /// /www/data
  ///
  /// /www/data/aaa
  ///
  /// 依次推入
  ///
  /// history大概就这样 [/ /www /www/data /www/data/aaa]
  ///
  /// 但是浏览器的history只有 [/www/data/aaa]
  @override
  Route<T> onGenerateRoute<T>(RouteSettings settings) {
    AjanuwRouteSettings ajanuwRouteSettings =
        AjanuwRouteSettings.extend(settings: settings);

    String routeName = ajanuwRouteSettings.name;

    // push('/home'); 绝对路径
    // push('home'); 相对路径
    // push('../../home'); 相对路径
    if (urlPath.isRelative(routeName) &&
        history.isNotEmpty &&
        history?.last != null) {
      routeName = urlPath.normalize(
        urlPath.join(
          removeFirstString(history.last.settings.name ?? ""),
          routeName,
        ),
      );
    } else {
      routeName = removeFirstString(routeName ?? '');
    }

    assert(!routeName.startsWith("/"));

    ajanuwRouteSettings = ajanuwRouteSettings.copyWith(name: routeName);

    // 使用[settings]在[routers]里面匹配到对应的路由
    AjanuwRouting routing = routings.find(routeName) ??
        routings.find(AjanuwRoute.notFoundRouteName);

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
    if (!_hasCanActivate(routing)) {
      return null;
    }

    if (routing.isRedirect) {
      return onGenerateRoute(
          ajanuwRouteSettings.copyWith(name: routing.route.redirectTo));
    }

    return routing.builder<T>();
  }

  @override
  dispose() {
    super.dispose();
  }
}
