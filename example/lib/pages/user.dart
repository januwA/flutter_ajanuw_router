import 'package:flutter/material.dart';
import 'package:example/main.dart';
import '../data/users.dart';

class User extends StatefulWidget {
  final int id;

  const User({Key key, @required this.id}) : super(key: key);

  @override
  _UserState createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    String name;
    if (users.map((u) => u.id).toList().indexOf(widget.id) > -1) {
      name = users.firstWhere((u) => u.id == widget.id).name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (name != null) Text('Hi i\'m "$name"') else Text('null'),
            RaisedButton(
              child: Text('to user settings'),
              onPressed: () {
                router.navigator.pushNamed('/users/${widget.id}/user-settings');
              },
            ),
            if (widget.id == 3)
              RaisedButton(
                child: Text('to user 1'),
                onPressed: () {
                  router.navigator.pushNamed('/users/1');
                },
              ),
          ],
        ),
      ),
    );
  }
}
