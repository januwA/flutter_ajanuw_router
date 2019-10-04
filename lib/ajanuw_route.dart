import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/path.dart';

import 'ajanuw_route_settings.dart';
import 'ajanuw_router.dart';

typedef AjanuwRouteBuilder = Widget Function(
    BuildContext conetxt, AjanuwRouteSettings settings);

class AjanuwRoute {
  /// '**'
  static const notFoundRouteName = '**';

  final bool fullscreenDialog;

  ///   Whether the route should remain in memory when it is inactive.
  /// 
  /// If this is true, then the route is maintained, so that any futures it is holding from the next route will properly resolve when the next route pops. If this is not necessary, this can be set to false to allow the framework to entirely discard the route's widget hierarchy when it is not visible.
  /// 
  /// The value of this getter should not change during the lifetime of the object. It is used by [createOverlayEntries], which is called by [install] near the beginning of the route lifecycle.
  /// 
  /// Copied from ModalRoute.
  final bool maintainState;

  /// Flutetr web document.title
  final String title;

  final Color color;

  /// 与之匹配的路径，即使用路由器匹配表示法的URL字符串。
  ///
  /// 默认为"/"（根路径）
  ///
  /// 不要再path前面添加'/'，如：
  ///
  /// ```dart
  /// path = '/home' // error
  /// path = 'home   // success
  /// ```
  final String path;

  /// 路径匹配时实例化的组件。
  /// 如果子路由指定组件，则可以为空。
  final AjanuwRouteBuilder builder;

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

  bool get isAbsolute => p.isAbsolute(path);
  bool get isRelative => p.isRelative(path);

  ///```dart
  /// path = ''
  /// ```
  bool get isEmpty => path.isEmpty;
  bool get isAnimatedRoute => transitionsBuilder != null;

  /// path = '**' 设置路由为404路由
  bool get isNotFoundRoute => path == notFoundRouteName;
  bool get isRedirect => redirectTo != null;

  /// 配置
  AjanuwRoute({
    @required this.path,
    this.transitionDuration,
    this.transitionsBuilder,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.title,
    this.color,
    this.builder,
    this.redirectTo,
    this.canActivate,
    this.canActivateChild,
    this.children,
  })  :
        // path 为必须参数
        assert(path != null),

        // path不能设置以'/'开始
        assert(!path.trim().startsWith('/')),

        // 必须要有能渲染的对象
        assert(builder != null ||
            builder == null && children != null ||
            redirectTo != null),

        // 强制使用'**'搭配'redirectTo'
        assert((() {
          if (path == notFoundRouteName) {
            return redirectTo != null;
          }
          return true;
        })());

  AjanuwRoute copyWith({
    String path,
    String parent,
    Duration transitionDuration,
    RouteTransitionsBuilder transitionsBuilder,
    bool fullscreenDialog,
    bool maintainState,
    String title,
    Color color,
    AjanuwRouteBuilder builder,
    String redirectTo,
    List<CanActivate> canActivate,
    List<CanActivateChild> canActivateChild,
    List<AjanuwRoute> children,
  }) {
    return AjanuwRoute(
      path: path ?? this.path,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionsBuilder: transitionsBuilder ?? this.transitionsBuilder,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      maintainState: maintainState ?? this.maintainState,
      title: title ?? this.title,
      color: color ?? this.color,
      builder: builder ?? this.builder,
      redirectTo: redirectTo ?? this.redirectTo,
      canActivate: canActivate ?? this.canActivate,
      canActivateChild: canActivateChild ?? this.canActivateChild,
      children: children ?? this.children,
    );
  }
}
