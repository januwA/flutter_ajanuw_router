import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ajanuw_route.dart';
import 'ajanuw_route_settings.dart';
import 'flutter_ajanuw_router.dart';
import 'util/path.dart';
import 'util/remove_first_string.dart';

class AjanuwRouting {
  final String path;
  final AjanuwRoute route;

  final AjanuwRouteSettings settings;
  String get url => p.normalize(p.join(AjanuwRouter.baseHref, settings.name));

  AjanuwRouteFactory get builder => (AjanuwRouteSettings settings) => pageRoute;

  /// 动态路由参数
  /// ```dart
  /// path = 'user/:id'
  ///
  /// navigator.pushNamed('/user/2');
  ///
  /// routing.paramMap['id']; // 2 is String
  /// ```
  Map<String, String> get paramMap => settings.paramMap;

  /// 这个参数在页面刷新就会为空
  Object get arguments => settings.arguments;

  /// 只有包含在[children]里面的路由，才设置parent
  final String parent;

  /// 使用'/'分隔[route.path]
  List<String> get pathSplit => path.split('/');

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
    if (type != AjanuwRouteType.dynamic) return null;
    String exp = '';
    for (var i = 0; i < pathSplit.length; i++) {
      String item = pathSplit[i];
      String expItem = '\/' + item;
      if (item.startsWith(':')) {
        expItem = '/([^/]+)';
      }
      exp += expItem;
    }
    exp = removeFirstString(exp);
    RegExp parseExp = RegExp("$exp", dotAll: true);
    return parseExp;
  }

  AjanuwRouteType get type {
    if (route.type == AjanuwRouteType.redirect) return AjanuwRouteType.redirect;
    if (AjanuwRoute.isDynamicRouting(path)) return AjanuwRouteType.dynamic;

    return AjanuwRouteType.normal;
  }

  AjanuwRouting({
    @required this.path,
    @required this.route,
    this.settings,
    this.parent = '',
  });

  AjanuwRouting copyWith({
    String path,
    AjanuwRoute route,
    AjanuwRouteSettings settings,
    String parent,
  }) {
    return AjanuwRouting(
      path: path ?? this.path,
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

  Widget _createBuilder(BuildContext context, AjanuwRoute route) {
    return route.title != null || route.color != null
        ? _createTitle(context, route)
        : route.builder(context, this);
  }

  PageRoute get pageRoute {
    if (route.type == AjanuwRouteType.redirect) return null;
    var _settings = settings.copyWith(name: url);
    if (route.isAnimatedRoute) {
      return PageRouteBuilder(
        settings: _settings,
        transitionDuration: route.transitionDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _createBuilder(context, route),
        transitionsBuilder: route.transitionsBuilder,
      );
    } else {
      return MaterialPageRoute(
        fullscreenDialog: route.fullscreenDialog,
        maintainState: route?.maintainState,
        builder: (context) => _createBuilder(context, route),
        settings: _settings,
      );
    }
  }

  @override
  String toString() {
    return """{
  "path": $path,
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
