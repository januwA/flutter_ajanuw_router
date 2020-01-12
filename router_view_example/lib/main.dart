import 'package:flutter/material.dart';

import 'package:flutter_ajanuw_router/ajanuw_route.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

import 'pages/animal.dart';
import 'pages/cats.dart';
import 'pages/dogs.dart';
import 'pages/dash.dart';
import 'pages/not-found.dart';
import 'pages/tab1.dart';
import 'pages/tab2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<AjanuwRoute> routes = [
      AjanuwRoute(
        initialRoute: true,
        path: 'dash',
        builder: (context, r) => Dash(),
        children: [
          AjanuwRoute(
            path: 'tab1',
            builder: (context, r) => Tab1(),
          ),
          AjanuwRoute(
            path: 'tab2',
            builder: (context, r) => Tab2(),
          ),
        ],
      ),
      AjanuwRoute(
        path: 'animal',
        builder: (context, r) => Animal(),
        children: [
          AjanuwRoute(
            path: 'dogs',
            builder: (context, r) => Dogs(),
          ),
          AjanuwRoute(
            path: 'cats',
            builder: (context, r) => Cats(),
          ),
        ],
      ),
      AjanuwRoute(
        path: 'not-found',
        builder: (context, r) => NotFound(),
      ),
      AjanuwRoute(
        path: "**",
        redirectTo: '/not-found',
      ),
    ];
    return MaterialApp(
      initialRoute: "dash",
      navigatorObservers: [ajanuwRouter.navigatorObserver],
      navigatorKey: ajanuwRouter.navigatorKey,
      onGenerateRoute: ajanuwRouter.forRoot(
        routes,
        printHistory: false,
      ),
    );
  }
}
