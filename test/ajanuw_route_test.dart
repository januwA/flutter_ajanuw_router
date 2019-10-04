import 'package:flutter/widgets.dart';
import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_test/flutter_test.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  AjanuwRoute route;
  Widget home;

  setUpAll(() {
    home = Home();
    route = AjanuwRoute(
      path: 'home',
      builder: (context, settings) => home,
    );
  });

  group('AjanuwRoute test.', () {
    test('path.', () {
      expect(route.path, 'home');
    });
    test('builder.', () {
      expect(
          route.builder != null ||
              route.builder == null && route.children != null,
          true);
    });
  });
}
