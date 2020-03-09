import 'package:flutter/widgets.dart';
import 'package:flutter_ajanuw_router/ajanuw_route_settings.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  final settings = RouteSettings(name: '/home', arguments: 'x');
  AjanuwRouteSettings ars;

  setUpAll(() {
    ars = AjanuwRouteSettings.extend(
      paramMap: {
        'id': '2',
      },
      settings: settings,
    );
  });

  test('test arguments', () {
    expect(ars.arguments, 'x');
  });
  test('test paramMap', () {
    expect(ars.paramMap['id'], '2');
  });

  test('test copyWith', () {
    ars = ars.copyWith(
      paramMap: {
        'id': '3',
      },
      name: '/www/home',
      arguments: ars.arguments,
    );
    expect(ars.paramMap['id'], '3');
    expect(ars.name, '/www/home');
    expect(ars.arguments, 'x');
  });
}
