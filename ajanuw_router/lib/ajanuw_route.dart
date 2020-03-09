import 'package:flutter/material.dart';
import 'ajanuw_routing.dart';
import 'flutter_ajanuw_router.dart';

enum AjanuwRouteType {
  /// { path="xxx", redirectTo='/home' }
  redirect,

  /// { path='users/:id' }
  dynamic,

  /// { path='home' }
  normal,
}

typedef AjanuwRouteBuilder<A> = Widget Function(
  BuildContext conetxt,
  AjanuwRouting<A> routing,
);

typedef TransitionDurationBuilder<A> = Duration Function(
  AjanuwRouting<A> routing,
);

final _textIsDynamicRouteExp = RegExp(r"\/?:[a-zA-Z]+");

class AjanuwRoute<A extends Object> {
  /// defualt '**'
  static const notFoundRouteName = "**";

  /// 检查是否为动态路由
  static bool isDynamicRouting(String path) =>
      _textIsDynamicRouteExp.hasMatch(path);

  /// Whether this page route is a full-screen dialog.
  ///
  /// In Material and Cupertino, being fullscreen has the effects of making
  /// the app bars have a close button instead of a back button. On
  /// iOS, dialogs transitions animate differently and are also not closeable
  /// with the back swipe gesture.
  final bool fullscreenDialog;

  /// Whether the route obscures previous routes when the transition is complete.
  ///
  /// When an opaque route's entrance transition is complete, the routes behind
  /// the opaque route will not be built to save resources.
  /// Only effective if [transitionsBuilder] is set
  final bool opaque;

  ///   Whether the route should remain in memory when it is inactive.
  ///
  /// If this is true, then the route is maintained, so that any futures it is holding from the next route will properly resolve when the next route pops. If this is not necessary, this can be set to false to allow the framework to entirely discard the route's widget hierarchy when it is not visible.
  ///
  /// The value of this getter should not change during the lifetime of the object. It is used by [createOverlayEntries], which is called by [install] near the beginning of the route lifecycle.
  ///
  /// Copied from ModalRoute.
  final bool maintainState;

  /// Flutetr web document.title
  ///
  /// Unusual behavior may occur, try setting [maintainState] to 'false'
  ///
  /// Please see instructions carefully [maintainState] property
  final String title;

  /// Acts on flutter_web
  final Color color;

  /// Whether you can dismiss this route by tapping the modal barrier.
  ///
  /// The modal barrier is the scrim that is rendered behind each route, which
  /// generally prevents the user from interacting with the route below the
  /// current route, and normally partially obscures such routes.
  ///
  /// For example, when a dialog is on the screen, the page below the dialog is
  /// usually darkened by the modal barrier.
  ///
  /// If [barrierDismissible] is true, then tapping this barrier will cause the
  /// current route to be popped (see [Navigator.pop]) with null as the value.
  ///
  /// If [barrierDismissible] is false, then tapping the barrier has no effect.
  ///
  /// If this getter would ever start returning a different color,
  /// [changedInternalState] should be invoked so that the change can take
  /// effect.
  ///
  /// See also:
  ///
  ///  * [barrierColor], which controls the color of the scrim for this route.
  ///  * [ModalBarrier], the widget that implements this feature.
  ///
  /// 简单点讲就是点击遮罩层是否关闭这个路由
  /// Only effective if [transitionsBuilder] is set
  final bool barrierDismissible;

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  ///
  /// The modal barrier is the scrim that is rendered behind each route, which
  /// generally prevents the user from interacting with the route below the
  /// current route, and normally partially obscures such routes.
  ///
  /// For example, when a dialog is on the screen, the page below the dialog is
  /// usually darkened by the modal barrier.
  ///
  /// The color is ignored, and the barrier made invisible, when [offstage] is
  /// true.
  ///
  /// While the route is animating into position, the color is animated from
  /// transparent to the specified color.
  ///
  /// If this getter would ever start returning a different color,
  /// [changedInternalState] should be invoked so that the change can take
  /// effect.
  ///
  /// See also:
  ///
  ///  * [barrierDismissible], which controls the behavior of the barrier when
  ///    tapped.
  ///  * [ModalBarrier], the widget that implements this feature.
  ///
  /// 设置遮罩层的颜色,默认为透明
  /// Only effective if [transitionsBuilder] is set
  final Color barrierColor;

  /// The semantic label used for a dismissible barrier.
  ///
  /// If the barrier is dismissible, this label will be read out if
  /// accessibility tools (like VoiceOver on iOS) focus on the barrier.
  ///
  /// The modal barrier is the scrim that is rendered behind each route, which
  /// generally prevents the user from interacting with the route below the
  /// current route, and normally partially obscures such routes.
  ///
  /// For example, when a dialog is on the screen, the page below the dialog is
  /// usually darkened by the modal barrier.
  ///
  /// If this getter would ever start returning a different color,
  /// [changedInternalState] should be invoked so that the change can take
  /// effect.
  ///
  /// See also:
  ///
  ///  * [barrierDismissible], which controls the behavior of the barrier when
  ///    tapped.
  ///  * [ModalBarrier], the widget that implements this feature.
  final String barrierLabel;

  /// 与之匹配的路径，即使用路由器匹配表示法的URL字符串。
  ///
  /// 不要再path前面添加'/'，如：
  ///
  /// ```dart
  /// path = '/home' // error
  /// path = 'home   // success
  /// ```
  final String path;

  /// The component that is instantiated when the paths match.
  /// It can be empty if it contains [children] or [redirectTo].
  final AjanuwRouteBuilder<A> builder;

  /// Animate navigation
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

  /// Can rely on parsing parameter to return a dynamic [Duration]
  /// Has priority over [transitionDuration]
  /// ```dart
  /// // example
  /// AjanuwRoute(
  ///   path: 'dog/:id',
  ///   builder: (context, r) => Dog(id: r.paramMap['id']),
  ///   transitionDurationBuilder: (AjanuwRouting r) {
  ///     final Map arguments = r.arguments;
  ///     final seconds = arguments != null && arguments['seconds'] != null? arguments['seconds'] : 2;
  ///     return Duration(seconds: seconds ?? 2);
  ///   },
  ///   transitionsBuilder: (context, animation, secondaryAnimation, child) {
  ///    final tween = Tween(begin: const Offset(1.0, 1.0), end: Offset.zero);
  ///     final curvedAnimation = CurvedAnimation(
  ///      parent: animation,
  ///       curve: const ElasticInOutCurve(),
  ///     );
  ///     return SlideTransition(
  ///       position: tween.animate(curvedAnimation),
  ///       child: child,
  ///     );
  ///   },
  /// ),
  /// ```
  final TransitionDurationBuilder<A> transitionDurationBuilder;

  ///是否为自定义动画路由
  bool get isAnimatedRoute => transitionsBuilder != null;

  /// 路径匹配时重定向到的URL。
  /// 如果URL以斜杠（/）开头，则为绝对值，否则相对于路径URL。
  /// 不存在时，路由器不重定向
  ///
  /// redirectTo 优先级高于 builder
  final String redirectTo;

  /// Handler to determine if routing is allowed for the current user
  /// Any user can activate by default.
  final List<CanActivate> canActivate;

  /// 一组指定嵌套路由的子Route对象的数组配置
  final List<AjanuwRoute> children;

  /// 关于[route]的类型
  ///
  /// 2. redirectTo != null 被断定为[AjanuwRouteType.redirect]
  ///
  /// 3. path=users/:id 动态路由[AjanuwRouteType.dynamic]
  ///
  /// 4. page=home 普通路由[AjanuwRouteType.normal]
  AjanuwRouteType get type {
    if (redirectTo != null) return AjanuwRouteType.redirect;

    /// 在这里并不能检测出嵌套的动态路由，如：
    /// [user -> :id -> settings] 在处理到settings时，被判断为了[AjanuwRouteType.normal]
    /// 只能检测到'user/:id/settings'这种一次写完的path
    /// 无法判断交给[AjanuwRouting]处理，在那里[path]将被打平为[url]
    if (isDynamicRouting(path)) return AjanuwRouteType.dynamic;

    return AjanuwRouteType.normal;
  }

  bool get isRedirect => type == AjanuwRouteType.redirect;
  bool get hasChildren => children != null;
  bool get hasBuilder => builder != null;

  toRouting(AjanuwRoutings routings, String parentPath) {
    if (isRedirect || hasBuilder) {
      routings.add(AjanuwRouting<A>(route: this, parent: parentPath));
    }
  }

  ///
  ///
  ///```dart
  /// AjanuwRoute(
  ///   path: 'home',
  ///   title: 'home',
  ///   builder: (context, routing) => Home(),
  /// )
  ///
  /// // Redirect
  /// AjanuwRoute(
  ///   path: '/index',
  ///   redirectTo: '/home',
  /// )
  ///
  /// // Dynamic routing
  /// AjanuwRoute(
  ///   path: 'cats/:id',
  ///   builder: (context, routing) => Cat(id: routing.paramMap['id']),
  /// )
  ///
  /// // Route interceptor
  /// AjanuwRoute(
  ///   path: 'admin',
  ///   builder: (context, r) => Admin(),
  ///   canActivate: [
  ///     (AjanuwRouting routing) {
  ///       if (authService.islogin) return true;
  ///       authService.redirectTo = routing.url;
  ///       router.pushNamed('/login');
  ///       return false;
  ///     }
  ///   ],
  ///   children: [
  ///     // Child routes will inherit parent permissions by default
  ///     AjanuwRoute(
  ///       path: 'add-user',
  ///       builder: (context, settings) => AddUser(),
  ///     ),
  ///   ],
  /// )
  ///
  /// // 404 redirect
  /// AjanuwRoute(
  ///   path: "**",
  ///   redirectTo: '/not-found',
  /// ),
  ///```
  ///
  AjanuwRoute({
    @required this.path,
    this.transitionDuration = kTabScrollDuration,
    this.opaque = true,
    this.barrierDismissible = false,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.barrierLabel,
    this.barrierColor,
    this.transitionsBuilder,
    this.title,
    this.color,
    this.builder,
    this.redirectTo,
    this.canActivate,
    this.children,
    this.transitionDurationBuilder,
  })  :
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
      children: children ?? this.children,
    );
  }

  @override
  String toString() {
    return """
    {
      "notFoundRouteName": $notFoundRouteName,
      "fullscreenDialog": $fullscreenDialog,
      "opaque": $opaque,
      "maintainState": $maintainState,
      "title": $title,
      "color": $color,
      "barrierDismissible": $barrierDismissible,
      "barrierColor": $barrierColor,
      "barrierLabel": $barrierLabel,
      "path": $path,
      "transitionDuration": $transitionDuration,
      "isAnimatedRoute": $isAnimatedRoute,
      "redirectTo": $redirectTo,
      "type": $type
    }
    """;
  }
}
