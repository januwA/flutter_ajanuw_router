import 'package:flutter/material.dart';

class ArgsPageArguments {
  final String name;
  final int id;

  ArgsPageArguments(this.name, this.id);
}

class ArgsPage extends StatefulWidget {
  @override
  _ArgsPageState createState() => _ArgsPageState();
}

class _ArgsPageState extends State<ArgsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ArgsPage'),
      ),
      body: Center(
        child: Text('ArgsPage work.'),
      ),
    );
  }
}
