import 'package:flutter/material.dart';

import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'util/path.dart';
import 'util/remove_first_string.dart';

/// 所有路由将被打平储存，并提供一些工具方法
class AjanuwRoutings {
  final Map<String, AjanuwRouting> routers = {};
  void add(AjanuwRouting value) => routers[value.path] = value;
  bool has(String name) => routers.containsKey(name);
  AjanuwRouting get(String name) => routers[name];

  /// 所有动态路由
  List<AjanuwRouting> get dynamicRoutings =>
      routers.values.where((routing) => routing.isDynamic).toList();

  AjanuwRouting findDynamic(String name) {
    return dynamicRoutings.firstWhere(
        (dynamicRouting) => _matchDynamicRoute(name, dynamicRouting),
        orElse: () => null);
  }

  AjanuwRouting find(String routeName) =>
      has(routeName) ? get(routeName) : findDynamic(routeName);

  /// /users/2 匹配 /users/:id
  bool _matchDynamicRoute(String routeName, AjanuwRouting dynamicRouting) {
    final Pattern pattern = '/';
    List<String> routeNameSplit = routeName.split(pattern);
    List<String> dynamicRouteNameSplit = dynamicRouting.path.split(pattern);
    final bool equalRouteLength =
        routeNameSplit.length == dynamicRouteNameSplit.length;
    return equalRouteLength &&
        dynamicRouting.exp.hasMatch(routeNameSplit.join(pattern));
  }
}

/// A，是arguments参数的类型
class AjanuwRouting<A> {
  final AjanuwRoute<A> route;

  /// users/:id
  String get path => urlPath.join(parent ?? "", route.path);
  List<String> get pathSplit => path.split('/');

  final AjanuwRouteSettings settings;

  /// users/1
  String get url => urlPath.normalize(urlPath.join("/", settings.name));

  /// Dynamic routing parameters
  /// ```dart
  /// path = 'user/:id'
  ///
  /// navigator.pushNamed('/user/1');
  ///
  /// routing.paramMap['id']; // 1 is String
  /// ```
  Map<String, String> get paramMap => settings.paramMap;

  /// flutter_web: 这个参数在页面刷新就会为空
  A get arguments => settings.arguments;

  /// T，是pop返回的数据类型
  Route<T> builder<T extends dynamic>() {
    assert(!route.isRedirect);
    var _settings = settings.copyWith(name: url);
    if (route.isAnimatedRoute) {
      return PageRouteBuilder<T>(
        settings: _settings,
        transitionDuration: route.transitionDurationBuilder != null
            ? route.transitionDurationBuilder(this)
            : route.transitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _createBuilder(context, route),
        transitionsBuilder: route.transitionsBuilder,
        opaque: route.opaque,
        barrierDismissible: route.barrierDismissible,
        barrierColor: route.barrierColor,
        barrierLabel: route.barrierLabel,
        maintainState: route.maintainState,
        fullscreenDialog: route.fullscreenDialog,
      );
    } else {
      return MaterialPageRoute<T>(
        fullscreenDialog: route.fullscreenDialog,
        maintainState: route.maintainState,
        builder: (context) => _createBuilder(context, route),
        settings: _settings,
      );
    }
  }

  /// 只有包含在[children]里面的路由，才设置parent
  final String parent;
  bool get hasParent => parent != null || parent != '';

  /// 在被判断为动态路由时，将会填充这个对象
  /// 解析出动态参数，和动态参数的位置
  List<DynamicRoutingParam> get params {
    if (type != AjanuwRouteType.dynamic) return null;
    List<DynamicRoutingParam> params = [];
    for (var i = 0; i < pathSplit.length; i++) {
      String item = pathSplit[i];
      if (item.startsWith(':')) {
        String name = item;
        int index = i;
        params.add(DynamicRoutingParam(name, index));
      }
    }
    return params;
  }

  /// 在被判断为动态路由时，将会填充这个对象
  /// 在访问动态路由时，将用[exp]解析url是否与路由匹配
  RegExp get exp {
    if (!isDynamic) return null;
    String exp = '';
    for (var i = 0; i < pathSplit.length; i++) {
      String item = pathSplit[i];
      String expItem = '\/' + item;
      if (item.startsWith(':')) {
        expItem = '/([^/]+)';
      }
      exp += expItem;
    }
    if (exp != null && exp.trim() != '') {
      exp = removeFirstString(exp);
    }
    RegExp parseExp = RegExp("$exp", dotAll: true);
    return parseExp;
  }

  AjanuwRouteType get type {
    if (route.type == AjanuwRouteType.redirect) return AjanuwRouteType.redirect;
    if (AjanuwRoute.isDynamicRouting(path)) return AjanuwRouteType.dynamic;

    return AjanuwRouteType.normal;
  }

  bool get isDynamic => type == AjanuwRouteType.dynamic;
  bool get isRedirect => type == AjanuwRouteType.redirect;

  AjanuwRouting({
    @required this.route,
    @required this.parent,
    this.settings,
  });

  AjanuwRouting copyWith({
    String path,
    AjanuwRoute route,
    AjanuwRouteSettings settings,
    String parent,
  }) {
    return AjanuwRouting<A>(
      route: route ?? this.route,
      settings: settings ?? this.settings,
      parent: parent ?? this.parent,
    );
  }

  /// 在操作系统中描述此应用的小部件。
  Widget _createTitle(BuildContext context, AjanuwRoute route) {
    return Title(
      title: route?.title,
      color: route?.color ?? Theme.of(context).primaryColor,
      child: route.builder(context, this),
    );
  }

  Widget _createBuilder(BuildContext context, AjanuwRoute<A> route) {
    return route.title != null || route.color != null
        ? _createTitle(context, route)
        : route.builder(context, this);
  }

  @override
  String toString() {
    return """{
  "path": $path,
  "url": $url,
  "route": $route,
  "parent": $parent,
  "params": $params,
  "exp": $exp,
  "settings": $settings,
}""";
  }
}

/// 路由上面的动态参数 /users/:username/books/:bookId
///
/// List<DynamicRoutingParam> [{ name: ':username', index: 1 }, { name: ':bookId', index: 5 }]
class DynamicRoutingParam {
  final String name;
  final int index;

  DynamicRoutingParam(this.name, this.index);

  @override
  String toString() {
    return "{ name: $name, index: $index }";
  }
}
