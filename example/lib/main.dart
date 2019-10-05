import 'package:example/router/main.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(routes, baseHref: '/www/v2'),

      /// 如果设置了这个，拦截将无效
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
