import 'dart:async';

import 'package:flutter/widgets.dart';

enum AjanuwRouteObserverType {
  didPush,
  didReplace,
  didPop,
  didRemove,
}

class AjanuwRouteObserverData {
  final AjanuwRouteObserverType type;
  final Route<dynamic> from;
  final Route<dynamic> to;

  AjanuwRouteObserverData({this.type, this.from, this.to});
}

class AjanuwRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final StreamController<AjanuwRouteObserverData> _listenner;
  AjanuwRouteObserver(this._listenner);

  /// router init
  /// pushNamed
  /// pushNamedAndRemoveUntil
  /// popAndPushNamed
  /// 向history推送线路
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didPush,
      from: previousRoute,
      to: route,
    ));
  }

  /// pushReplacementNamed
  /// 将history最后一个route替换为新route
  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didReplace,
      from: oldRoute,
      to: newRoute,
    ));
  }

  /// pop
  /// popAndPushNamed
  /// popUntil
  /// 移除最后一条线路
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didPop,
      from: route,
      to: previousRoute,
    ));
  }

  @override
  void didRemove(Route from, Route to) {
    super.didRemove(from, to);
    _listenner.sink.add(AjanuwRouteObserverData(
      type: AjanuwRouteObserverType.didRemove,
      from: from,
      to: to,
    ));
  }
}
