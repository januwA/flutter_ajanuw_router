import 'package:flutter/widgets.dart';

/// 扩展[RouteSettings]
/// 增加[paramMap]属性，用来保存动态路由的参数
class AjanuwRouteSettings extends RouteSettings {
  final Map<String, dynamic> paramMap;

  AjanuwRouteSettings({
    this.paramMap,
    String name,
    bool isInitialRoute,
    Object arguments,
  }) : super(
          name: name,
          isInitialRoute: isInitialRoute ?? false,
          arguments: arguments,
        );

  AjanuwRouteSettings.extend({
    this.paramMap,
    RouteSettings settings,
  }) : super(
          name: settings.name,
          isInitialRoute: settings.isInitialRoute,
          arguments: settings.arguments,
        );

  @override
  AjanuwRouteSettings copyWith({
    Map<String, dynamic> paramMap,
    String name,
    bool isInitialRoute,
    Object arguments,
  }) {
    return AjanuwRouteSettings(
      paramMap: paramMap ?? this.paramMap,
      name: name ?? this.name,
      isInitialRoute: isInitialRoute ?? this.isInitialRoute,
      arguments: arguments ?? this.arguments,
    );
  }
}
