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
  AjanuwRouter router;
  Widget home;

  setUpAll(() {
    router.forRoot([
      AjanuwRoute(
        path: '',
        redirectTo: 'home',
      ),
      AjanuwRoute(
        path: 'home',
        builder: (c, s) => home,
      ),
      AjanuwRoute(
        path: 'not-found',
        builder: (c, s) => home,
      ),
      AjanuwRoute(
        path: '**',
        redirectTo: '/not-found',
      ),
    ]);
    home = Home();
  });
}
