import 'package:example/service/auth.service.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Login work.'),
            RaisedButton(
              child: Text('login'),
              onPressed: () {
                authService.login();
              },
            )
          ],
        ),
      ),
    );
  }
}
