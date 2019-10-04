import 'package:example/router/main.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      navigatorKey: router.navigatorKey,
      onGenerateRoute: router.forRoot(routes),

      /// 如果以防万一，可以把这个设置上
      // onUnknownRoute: (s) {},
    );
  }
}
