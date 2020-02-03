import 'package:example/main.dart';
import 'package:flutter/material.dart';

import 'args.dart';

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
            onPressed: () => router.pushNamed(
              '/users',
              arguments: 'x',
            ),
          ),
          RaisedButton(
            child: Text('admin'),
            onPressed: () => router.pushNamed('/admin'),
          ),
          RaisedButton(
            child: Text('add user'),
            onPressed: () =>
                router.pushNamed<String>('/admin/add-user').then(print),
          ),
          RaisedButton(
            child: Text('dog 1'),
            onPressed: () {
              router.pushNamed<String>('/dog/1').then((s) {
                print(s);
              });
            },
          ),
          RaisedButton(
            child: Text('login'),
            onPressed: () => router.pushNamed('/login'),
          ),
          RaisedButton(
            child: Text('redirect to dynamic path'),
            onPressed: () => router.pushNamed('/aa'),
          ),
          RaisedButton(
            child: Text('to home'),
            onPressed: () {
              router.pushNamed('/');
            },
          ),
          RaisedButton(
            child: Text('ArgsPage'),
            onPressed: () {
              router.pushNamed(
                '/arg',
                arguments: ArgsPageArguments("ajanuw", 1),
              );
            },
          ),
          RaisedButton(
            child: Text('Other'),
            onPressed: () {
              router.pushNamed('/other');
            },
          ),
        ],
      ),
    );
  }
}
