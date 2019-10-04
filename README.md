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
import 'package:flutter_ajanuw_router/ajanuw_router.dart';

final AjanuwRouter router = AjanuwRouter(maintainState: false);
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

  List<AjanuwRoute> routes = [
  AjanuwRoute(
    path: '/',
    redirectTo: '/home',
  ),
  AjanuwRoute(
    path: '/home',
    title: 'home',
    builder: (context, settings) => Home(),
  ),
  AjanuwRoute(
    path: '/login',
    title: '登陆',
    color: Colors.red,
    builder: (context, settings) => Title(
      title: '登陆',
      color: Theme.of(context).primaryColor,
      child: Login(),
    ),
  ),
  AjanuwRoute(
    path: '/admin',
    title: '控制台',
    builder: (context, settings) => Admin(),
    canActivate: [
      (AjanuwRouting routing) {
        bool isLogin = authService.islogin;
        if (isLogin) return true;
        authService.redirectTo = routing.url;
        print('未登录，重定向登陆页面!!');
        router.navigator.pushNamed('/login');
        return false;
      }
    ],
    children: [
      AjanuwRoute(
        title: '添加用户',
        path: '/add-user',
        builder: (context, settings) => AddUser(),
      ),
    ],
  ),
  AjanuwRoute(
    title: '用户组',
    path: '/users',
    builder: (context, settings) => Users(),
    children: [
      AjanuwRoute(
        title: '用户详情',
        path: '/:id',
        canActivate: [
          (AjanuwRouting routing) {
            // 没有id拒绝访问
            print(routing.settings.paramMap);
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
        builder: (BuildContext context, settings) {
          // 其实解析参数，放在[User]页面解析比较好，因为可以预防各种问题
          int id = int.parse(settings.paramMap['id']);
          return User(id: id);
        },
        children: [
          AjanuwRoute(
            title: '设置',
            path: '/user-settings',
            builder: (context, settings) => UserSettings(),
          ),
        ],
      ),
    ],
  ),
  AjanuwRoute(
    title: '页面未找到',
    path: '/not-found',
    builder: (context, settings) => NotFound(),
  ),
  AjanuwRoute(
    path: "**",
    redirectTo: '/not-found',
  ),
    ]

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(routes),

      /// You can set this
      // onUnknownRoute: (s) {},
    );
  }
}
```

## How to navigate?

```dart
router.navigator.pushNamed('/users');
router.navigator.pushNamed('/users/${user.id}');
router.navigator.pushNamed('/users/${user.id}/user-settings');

router.navigator.pushNamed('/admin');
router.navigator.pushNamed('/admin/add-user');

router.navigator.pushNamed('/login')
```