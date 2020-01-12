import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

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
    );
    home = Home();
  });

  test('routers is not empty', () {
    for (var item in router.routings.routers.entries) {
      print('-' * 10);
      print('key: ${item.key}');
      print('parent: ${item.value.parent}');

      print('routing.path: ${item.value.path}');
      print('route.path: ${item.value.route.path}');

      print('routing.type: ${item.value.type}');
      print('route.type: ${item.value.route.type}');

      print('redirectTo: ${item.value.route.redirectTo}');
      print('exp: ${item.value.exp}');
      print('-' * 10);
    }
    expect(router.routings.routers.keys.length != 0, true);
  }, skip: false);

  test('test exp match of dynamic route', () {
    expect(router.routings.routers['users/:id'].exp.hasMatch('users/3'), true);
    expect(router.routings.routers['users/:id'].exp.hasMatch('dogs/3'), false);
    expect(
        router.routings.routers['users/:id/about'].exp.hasMatch('users/3/about'),
        true);
    expect(
        router.routings.routers['users/:id/settings'].exp
            .hasMatch('users/3/about'),
        false);
  });
}
