import 'ajanuw_routing.dart';

/// 所有路由将被打平储存，并提供一些工具方法
class AjanuwRoutings {
  final Map<String, AjanuwRouting> routers = {};
  void add(AjanuwRouting value) => routers[value.path] = value;
  bool has(String name) => routers.containsKey(name);
  AjanuwRouting get(String name) => routers[name];

  AjanuwRouting get initialRoute {
    var r = routers.entries.firstWhere((item) => item.value.route.initialRoute,
        orElse: () => null);
    if (r != null)
      return r.value;
    else
      return null;
  }

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
