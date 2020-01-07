import 'package:example/main.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          RaisedButton(
            child: Text('users'),
            onPressed: () {
              router.navigator.pushNamed(
                '/users',
                arguments: 'x',
              );
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
            child: Text('dog 1'),
            onPressed: () {
              Navigator.of(context).pushNamed('/dog/1').then((s) {
                print(s as String);
              });
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
          Builder(
            builder: (context) => RaisedButton(
              child: Text('Display a snackbar'),
              onPressed: () {
                final snackBar = SnackBar(
                  content: Text('Yay! A SnackBar!'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Some code to undo the change.
                    },
                  ),
                );
                Scaffold.of(context).showSnackBar(snackBar);
              },
            ),
          ),
          RaisedButton(
            child: Text('Other'),
            onPressed: () {
              router.navigator.pushNamed('/other');
            },
          ),
        ],
      ),
    );
  }
}
