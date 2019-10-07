import 'package:flutter/material.dart';

class Dog extends StatefulWidget {
  final String id;

  const Dog({Key key, this.id}) : super(key: key);
  @override
  _DogState createState() => _DogState();
}

class _DogState extends State<Dog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog'),
      ),
      body: Center(
        child: Text('Dog work. ${widget.id}'),
      ),
    );
  }
}
