import 'package:example/main.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('users'),
              onPressed: () {
                router.navigator.pushNamed('/users');
              },
            ),
            RaisedButton(
              child: Text('admin'),
              onPressed: () {
                router.navigator.pushNamed('/admin');
              },
            ),
            RaisedButton(
              child: Text('add user'),
              onPressed: () {
                router.navigator.pushNamed('/admin/add-user');
              },
            ),
            RaisedButton(
              child: Text('login'),
              onPressed: () {
                router.navigator.pushNamed('/login');
              },
            ),
            RaisedButton(
              child: Text('redirect to dynamic path'),
              onPressed: () {
                router.navigator.pushNamed('/aa');
              },
            ),
            RaisedButton(
              child: Text('to home'),
              onPressed: () {
                router.navigator.pushNamed('/');
              },
            ),
            RaisedButton(
              child: Text('Other'),
              onPressed: () {
                router.navigator.pushNamed('/aaa');
              },
            ),
          ],
        ),
      ),
    );
  }
}
