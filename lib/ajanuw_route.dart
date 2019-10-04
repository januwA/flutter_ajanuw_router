import 'package:flutter/material.dart';

import 'ajanuw_route_settings.dart';
import 'ajanuw_router.dart';

class AjanuwRoute {
  /// '**'
  static const notFoundRouteName = '**';

  final String parent = '/';
  final bool fullscreenDialog;
  final bool maintainState;

  /// Flutetr web document.title
  final String title;

  final Color color;

  /// 与之匹配的路径，即使用路由器匹配表示法的URL字符串。
  /// 默认为"/"（根路径）
  ///
  /// path='home' 相对路径
  final String path;

  /// 路径匹配时实例化的组件。
  /// 如果子路由指定组件，则可以为空。
  final Widget Function(BuildContext conetxt, AjanuwRouteSettings settings)
      builder;

  /// 为导航设置动画
  ///
  /// ```dart
  /// // example
  /// AjanuwRoute(
  ///   path: '/login',
  ///   builder: (context, settings) => Title(
  ///     title: 'User Login',
  ///     color: Theme.of(context).primaryColor,
  ///     child: Login(),
  ///   ),
  ///   transitionsBuilder: (context, animation, secondaryAnimation, child) {
  ///     var begin = Offset(1.0, 1.0);
  ///     var end = Offset.zero;
  ///     var curve = Curves.ease;
  ///     var tween = Tween(begin: begin, end: end);
  ///     var curvedAnimation = CurvedAnimation(
  ///       parent: animation,
  ///       curve: curve,
  ///     );
  ///     return SlideTransition(
  ///       position: tween.animate(curvedAnimation),
  ///       child: child,
  ///     );
  ///   },
  /// ```
  final RouteTransitionsBuilder transitionsBuilder;

  /// The duration the transition lasts.
  final Duration transitionDuration;

  /// 路径匹配时重定向到的URL。
  /// 如果URL以斜杠（/）开头，则为绝对值，否则相对于路径URL。
  /// 不存在时，路由器不重定向
  ///
  /// redirectTo 优先级高于 builder
  final String redirectTo;

  /// 处理程序，以确定是否允许当前用户使用路由
  /// 默认情况下，任何用户都可以激活。
  final List<CanActivate> canActivate;

  /// TODO: 暂未实现
  final List<CanActivateChild> canActivateChild;

  /// 一组指定嵌套路由的子Route对象的数组配置
  final List<AjanuwRoute> children;

  bool get isAbsolute => path.startsWith('/');
  bool get isRelative => !path.startsWith('/');
  bool get isEmpty => path.isEmpty;
  bool get isAnimatedRoute => transitionsBuilder != null;

  /// path = '**' 设置路由为404路由
  bool get isNotFoundRoute => path == notFoundRouteName;
  bool get isRedirect => redirectTo != null;

  AjanuwRoute({
    String path,
    this.transitionDuration,
    this.transitionsBuilder,
    this.fullscreenDialog = false,
    this.maintainState,
    this.title,
    this.color,
    this.builder,
    this.redirectTo,
    this.canActivate,
    this.canActivateChild,
    this.children,
  })  : path = path.trim(),
        assert(path != null),
        assert((() {
          return builder != null || builder == null && children != null || redirectTo != null;
        })());
}
