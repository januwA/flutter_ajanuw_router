import 'package:example/pages/args.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/ajanuw_routing.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

import 'pages/dog.dart';
import 'pages/add_user.dart';
import 'pages/admin.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/not-found.dart';
import 'pages/user-settings.dart';
import 'pages/users.dart';
import 'pages/user.dart';
import 'service/auth.service.dart';

AjanuwRouter router = AjanuwRouter(printHistory: true);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<AjanuwRoute> routes = [
      AjanuwRoute<ArgsPageArguments>(
        path: 'arg',
        builder: (c, r) {
          return ArgsPage(
            name: r.arguments.name,
            id: r.arguments.id,
          );
        },
      ),
      AjanuwRoute(
        path: '',
        redirectTo: '/home',
      ),
      AjanuwRoute(
        path: 'aa',
        redirectTo: '/users/2',
      ),
      AjanuwRoute(
        path: 'home',
        title: 'home',
        builder: (context, r) => Home(),
      ),
      AjanuwRoute(
        path: 'dog/:id',
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (context, r) => Dog(id: r.paramMap['id']),
        transitionDurationBuilder: (_) => Duration(seconds: 2),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero);
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: const ElasticInOutCurve(),
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
      AjanuwRoute(
        path: 'login',
        title: 'Login',
        builder: (context, r) => Title(
          title: 'Login',
          color: Theme.of(context).primaryColor,
          child: Login(),
        ),
        transitionDuration: Duration(seconds: 2),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween = Tween(begin: begin, end: end);
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
      AjanuwRoute(
        path: 'admin',
        title: 'Admin',
        builder: (context, r) => Admin(),
        canActivate: [
          (AjanuwRouting routing) {
            if (authService.islogin) return true;
            print("routing.url: " + routing.url);
            authService.redirectTo = routing.url;
            router.pushNamed('/login');
            return false;
          }
        ],
        children: [
          AjanuwRoute(
            title: 'Add User',
            path: 'add-user',
            builder: (context, settings) => AddUser(),
          ),
        ],
      ),
      AjanuwRoute(
        title: 'Users',
        path: 'users',
        builder: (context, r) => Users(),
        children: [
          AjanuwRoute(
            title: 'User details',
            path: ':id',
            canActivate: [
              (AjanuwRouting routing) {
                // No id denied access
                final paramMap = routing.settings.paramMap;
                if (paramMap['id'] == null) {
                  router.navigator.pushReplacementNamed('/users');
                  return false;
                }

                try {
                  int.parse(paramMap['id']);
                  return true;
                } catch (e) {
                  return false;
                }
              }
            ],
            builder: (BuildContext context, r) {
              // In fact, it is better to parse the parameters on the [User] page, because it can prevent various problems
              int id = int.parse(r.paramMap['id']);
              return User(id: id);
            },
            children: [
              AjanuwRoute(
                title: 'settings',
                path: 'user-settings',
                builder: (context, settings) => UserSettings(),
              ),
            ],
          ),
        ],
      ),
      AjanuwRoute(
        title: 'Page Not Found',
        path: 'not-found',
        builder: (context, r) => NotFound(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = 0.0;
          var end = 1.0;
          var curve = Curves.ease;
          var tween = Tween<double>(begin: begin, end: end);
          var curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return ScaleTransition(
            scale: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
      AjanuwRoute(
        path: "**",
        redirectTo: '/not-found',
      ),
    ];

    return MaterialApp(
      initialRoute: 'users',
      navigatorObservers: [router.navigatorObserver],
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(routes),

      /// If this is set, interception will not work
      // onUnknownRoute: (s) {
      //   return MaterialPageRoute(
      //     builder: (_) => Scaffold(
      //       body: Center(child: Text('data'),),
      //     ),
      //   );
      // },
    );
  }
}
