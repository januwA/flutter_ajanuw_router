import 'package:flutter/widgets.dart';
import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';
import 'package:flutter_test/flutter_test.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

void main() {
  AjanuwRouter router = AjanuwRouter();
  Widget home;

  setUpAll(() {
    final builder = (c, s) => home;
    router.forRoot(
      [
        AjanuwRoute(
          path: '',
          redirectTo: '/home',
        ),
        AjanuwRoute(
          path: 'home',
          builder: builder,
        ),
        AjanuwRoute(
          path: 'not-found',
          builder: builder,
        ),
        AjanuwRoute(
          path: 'dogs',
          builder: builder,
          children: [
            AjanuwRoute(
              path: ':id',
              builder: builder,
            ),
          ],
        ),
        AjanuwRoute(
          path: 'users',
          builder: builder,
          children: [
            AjanuwRoute(
              path: ':id',
              builder: builder,
              children: [
                AjanuwRoute(
                  path: 'settings',
                  builder: builder,
                ),
                AjanuwRoute(
                  path: 'about',
                  builder: builder,
                ),
              ],
            ),
          ],
        ),
        AjanuwRoute(
          path: '**',
          redirectTo: '/not-found',
        ),
      ],
      initialRoute: '/',
    );
    home = Home();
  });

  test('routers is not empty', () {
    for (var item in AjanuwRouter.routers.entries) {
      print('');
      print('-' * 10);
      print('key: ${item.key}');

      print('routing.path: ${item.value.path}');
      print('route.path: ${item.value.route.path}');

      print('routing.type: ${item.value.type}');
      print('route.type: ${item.value.route.type}');

      print('redirectTo: ${item.value.route.redirectTo}');
      print('exp: ${item.value.exp}');
      print('-' * 10);
    }
    expect(AjanuwRouter.routers.keys.length != 0, true);
  }, skip: false);

  test('test exp match of dynamic route', () {
    expect(AjanuwRouter.routers['/users/:id'].exp.hasMatch('/users/3'), true);
    expect(AjanuwRouter.routers['/users/:id'].exp.hasMatch('/dogs/3'), false);
    expect(
        AjanuwRouter.routers['/users/:id/about'].exp.hasMatch('/users/3/about'),
        true);
    expect(
        AjanuwRouter.routers['/users/:id/settings'].exp
            .hasMatch('/users/3/about'),
        false);
  });
}
