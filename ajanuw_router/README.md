## A router used on Flutter and Flutter WEB.

This library can solve most problems (dynamic routing, route interceptor, transparent routing), but not all problems.

## run demo

```shell
$ flutter channel master
$ flutter upgrade
$ flutter config --enable-web
$ git clone https://github.com/januwA/flutter_ajanuw_router.git
$ cd flutter_ajanuw_router/example
$ flutter run -d chrome
```

## install

```dart
dependencies:
  flutter_ajanuw_router:
```


## usage

```dart
// main.dart
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

// [printHistory] Purpose of commissioning
AjanuwRouter router = AjanuwRouter(printHistory: true);

// as:
// I/flutter (20260): (/users)
// I/flutter (20260): (/users, /home)
// I/flutter (20260): (/users, /home, /login)
// I/flutter (20260): (/users, /home, /admin)
// I/flutter (20260): (/users, /home)

final List<AjanuwRoute> routes = [
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
    opaque: false, // Only effective if [transitionsBuilder] is set
    barrierDismissible: true, // Only effective if [transitionsBuilder] is set
    barrierColor: Colors.black54, // Only effective if [transitionsBuilder] is set
    builder: (context, r) => Dog(id: r.paramMap['id']),
    transitionDurationBuilder: (AjanuwRouting r) {
      final Map arguments = r.arguments;
      final seconds = arguments != null && arguments['seconds'] != null? arguments['seconds'] : 2;
      return Duration(seconds: seconds ?? 2);
    },
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
        print(routing.url);
        authService.redirectTo = routing.url;
        router.navigator.pushNamed('/login');
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

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final onGenerateRoute = router.forRoot(routes);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'users',
      navigatorObservers: [router.navigatorObserver],
      navigatorKey: router.navigatorKey,
      onGenerateRoute: onGenerateRoute,

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
```

## How to navigate?

```dart
router.navigator.pushNamed('/');
router.navigator.pushNamed('/admin');

router.navigator.pushNamed('/dog/1');


router.navigator.pushNamed('/users', arguments: 'x',); // /users
router.navigator.pushNamed(1, arguments: user); // /users/1
router.navigator.pushNamed('user-settings'); // /users/1/user-settings
router.navigator.pushNamed('../../3'); // /users/3

router.navigator.pushNamedAndRemoveUntil('/', (_) => false); // [ /home ]
router.navigator.pushNamedAndRemoveUntil('/users', ModalRoute.withName('/'));// error: There is no / in the history, because / is the redirect route
router.navigator.pushNamedAndRemoveUntil('/users', ModalRoute.withName('/home'));// success: [/home, /users]

// or use [Navigator]

Navigator.of(context).pushNamed('/');
Navigator.of(context).pushNamed('/admin');
Navigator.of(context).pushNamed('/dog/1');
Navigator.of(context).pushNamed('/users', arguments: 'x',);
Navigator.of(context).pushNamed(1, arguments: user);
Navigator.of(context).pushNamed('user-settings');
Navigator.of(context).pushNamed('../../3');
Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
Navigator.of(context).pushNamedAndRemoveUntil('/users', ModalRoute.withName('/home'));

// or v0.3.1
router.pushNamed<String>('/dog/1').then((s) {
  print(s);
});
```

## About return value
```dart
// Error, you may get the error: type 'PageRouteBuilder <dynamic>' is not a subtype of type 'Route <String>'
Navigator.of(context).pushNamed<String>('/dog/1').then((s) {
  print(s);
});

// Only in this way
// You have a good way, please tell me.
Navigator.of(context).pushNamed('/dog/1').then((s) {
  print(s as String);
});

// v0.3.1 This version rewrites some methods to fix the above problems
router.pushNamed<String>('/dog/1').then((s) {
  print(s);
});
```

## Set the `arguments` type
```dart
// type
class ArgsPageArguments {
  final String name;
  final int id;

  ArgsPageArguments(this.name, this.id);
}

// init
AjanuwRoute<ArgsPageArguments>(
  path: 'arg',
  builder: (c, r) {
    print(r.arguments.name);
    return ArgsPage();
  },
)

// push
router.pushNamed(
  '/arg',
  arguments: ArgsPageArguments("ajanuw", 1),
);
```

## Generate arguments

1) install build_runner and ajanuw_router_generator
```yaml
dev_dependencies:
  ...

  build_runner:
  ajanuw_router_generator:
```

2) use, Will generate `DogArguments`
```dart
import 'package:flutter_ajanuw_router/ajanuw_route_argument.dart';

part 'dog.g.dart';

@ara
class Dog extends StatefulWidget {
 final String id;
  const Dog({Key key, this.id}) : super(key: key);
  @override
  _DogState createState() => _DogState();
}
```

## test
```
λ flutter test
λ flutter test ./test/ajanuw_route_test.dart
```