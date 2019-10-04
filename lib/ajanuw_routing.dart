import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/ajanuw_route.dart';

import 'ajanuw_route_settings.dart';
import 'ajanuw_router.dart';

class AjanuwRouting {
  final AjanuwRoute route;
  final List<DynamicRoutingParam> params;
  final RegExp exp;
  AjanuwRouteFactory get builder => (AjanuwRouteSettings settings) =>
      _createPageRouteBuilder(settings: settings);

  /// 无论什么路由，可能又会加上访问权限
  // final List<CanActivate> canActivate;
  // final List<CanActivateChild> canActivateChild;
  // final String redirectTo;
  final AjanuwRouteSettings settings;

  /// 只有包含在[children]里面的路由，才设置parent
  final String parent;
  String get url => settings?.name;

  AjanuwRouting({
    @required this.route,
    this.params,
    this.parent,
    this.exp,
    this.settings,
  });

  AjanuwRouting copyWith({
    AjanuwRoute route,
    List<DynamicRoutingParam> params,
    RegExp exp,
    AjanuwRouteFactory builder,
    List<CanActivate> canActivate,
    List<CanActivateChild> canActivateChild,
    String redirectTo,
    AjanuwRouteSettings settings,
    String parent,
  }) {
    return AjanuwRouting(
      route: route ?? this.route,
      params: params ?? this.params,
      exp: exp ?? this.exp,
      settings: settings ?? this.settings,
      parent: parent ?? this.parent,
    );
  }

  /// 将[AjanuwRoute]的配置生成对应的[PageRoute]
  Route<T> _createPageRouteBuilder<T>({
    AjanuwRouteSettings settings,
  }) {
    // 重定向路由和404路由，没有直接的渲染对象
    if (route.isNotFoundRoute || route.isRedirect) return null;
    if (route.transitionsBuilder != null) {
      return PageRouteBuilder(
        settings: settings,
        transitionDuration: route?.transitionDuration ?? kTabScrollDuration,
        pageBuilder: (context, animation, secondaryAnimation) =>
            route.title != null || route.color != null
                ? Title(
                    title: route?.title,
                    color: route?.color ?? Theme.of(context).primaryColor,
                    child: route.builder(context, settings),
                  )
                : route.builder(context, settings),
        transitionsBuilder: route.transitionsBuilder,
      );
    } else {
      return MaterialPageRoute(
        fullscreenDialog: route.fullscreenDialog,
        maintainState: route?.maintainState,
        // maintainState: false,
        builder: (context) => route.title != null || route.color != null
            ? Title(
                title: route?.title,
                color: route?.color ?? Theme.of(context).primaryColor,
                child: route.builder(context, settings),
              )
            : route.builder(context, settings),
        // builder: (context) => route.builder(context, settings),
        settings: settings,
      );
    }
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
