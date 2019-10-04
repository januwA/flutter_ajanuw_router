import 'ajanuw_route_settings.dart';
import 'ajanuw_router.dart';

class AjanuwRouting {
  final List<DynamicRoutingParam> params;
  final RegExp exp;
  final AjanuwRouteFactory builder;

  /// 无论什么路由，可能又会加上访问权限
  final List<CanActivate> canActivate;
  final List<CanActivateChild> canActivateChild;
  final String redirectTo;
  final AjanuwRouteSettings settings;

  /// 只有包含在[children]里面的路由，才设置parent
  final String parent;
  String get url => settings?.name;

  AjanuwRouting({
    this.params,
    this.parent,
    this.exp,
    this.builder,
    this.canActivate,
    this.canActivateChild,
    this.redirectTo,
    this.settings,
  });

  AjanuwRouting copyWith({
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
      params: params ?? this.params,
      exp: exp ?? this.exp,
      builder: builder ?? this.builder,
      canActivate: canActivate ?? this.canActivate,
      redirectTo: redirectTo ?? this.redirectTo,
      settings: settings ?? this.settings,
      canActivateChild: canActivateChild ?? this.canActivateChild,
      parent: parent ?? this.parent,
    );
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
