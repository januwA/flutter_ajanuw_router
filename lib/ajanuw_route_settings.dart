import 'package:flutter/widgets.dart';

/// 扩展[RouteSettings]
/// 增加[paramMap]属性，用来保存动态路由的参数
class AjanuwRouteSettings extends RouteSettings {
  final Map<String, String> paramMap;

  AjanuwRouteSettings({
    this.paramMap,
    String name,
    Object arguments,
  }) : super(
          name: name,
          arguments: arguments,
        );

  AjanuwRouteSettings.extend({
    this.paramMap,
    RouteSettings settings,
  }) : super(
          name: settings.name,
          arguments: settings.arguments,
        );

  @override
  AjanuwRouteSettings copyWith({
    Map<String, String> paramMap,
    String name,
    bool isInitialRoute,
    Object arguments,
    String path,
  }) {
    return AjanuwRouteSettings(
      paramMap: paramMap ?? this.paramMap,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }

  @override
  String toString() {
    return """{
      "paramMap": $paramMap,
      "name": $name,
      "arguments": $arguments,
  }""";
  }
}
