## A router used on Flutter and Flutter WEB.

This library can solve most problems, but it can't solve all problems.

> There may be many bugs, please use them carefully on important projects.


## install

```dart
dependencies:
  flutter_ajanuw_router:
```


## usage

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

final AjanuwRouter router = AjanuwRouter();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<AjanuwRoute> routes = [
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
        builder: (context, settings) => Home(),
      ),
      AjanuwRoute(
        path: 'login',
        title: '登陆',
        builder: (context, settings) => Title(
          title: '登陆',
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
        title: '控制台',
        builder: (context, settings) => Admin(),
        canActivate: [
          (AjanuwRouting routing) {
            bool isLogin = authService.islogin;
            if (isLogin) return true;
            print(routing.url); // baseHref+path
            print(routing.path); // path
            authService.redirectTo = routing.path;
            print('未登录，重定向登陆页面!!');
            router.navigator.pushNamed('/login');
            return false;
          }
        ],
        children: [
          AjanuwRoute(
            title: '添加用户',
            path: 'add-user',
            builder: (context, settings) => AddUser(),
          ),
        ],
      ),
      AjanuwRoute(
        title: '用户组',
        path: 'users',
        builder: (context, settings) => Users(),
        children: [
          AjanuwRoute(
            title: '用户详情',
            path: ':id',
            canActivate: [
              (AjanuwRouting routing) {
                // 没有id拒绝访问
                final paramMap = routing.settings.paramMap;
                print(paramMap);
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
            builder: (BuildContext context, settings) {
              // 其实解析参数，放在[User]页面解析比较好，因为可以预防各种问题
              int id = int.parse(settings.paramMap['id']);
              return User(id: id);
            },
            children: [
              AjanuwRoute(
                title: '设置',
                path: 'user-settings',
                builder: (context, settings) => UserSettings(),
              ),
            ],
          ),
        ],
      ),
      AjanuwRoute(
        title: '页面未找到',
        path: 'not-found',
        builder: (context, settings) => NotFound(),
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

    String initialRoute = '/';
    return MaterialApp(
      initialRoute: initialRoute,
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(
        routes,
        initialRoute: initialRoute,
      ),
    );
  }
}
```

## How to navigate?

```dart
router.navigator.pushNamed('/users');
router.navigator.pushNamed('/users/${user.id}');
router.navigator.pushNamed('/users/${user.id}/user-settings');

router.navigator.pushNamed('/admin/add-user');
```