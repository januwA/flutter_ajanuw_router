import 'package:example/pages/add_user.dart';
import 'package:example/pages/admin.dart';
import 'package:example/pages/home.dart';
import 'package:example/pages/login.dart';
import 'package:example/pages/not-found.dart';
import 'package:example/pages/user-settings.dart';
import 'package:example/pages/user.dart';
import 'package:example/pages/users.dart';
import 'package:example/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/ajanuw_router.dart';
import 'package:flutter_ajanuw_router/ajanuw_routing.dart';

final AjanuwRouter router = AjanuwRouter(
    // maintainState: false,
    );

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
