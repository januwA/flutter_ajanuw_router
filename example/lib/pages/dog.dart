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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Dog work. ${widget.id}',
                  style: Theme.of(context).textTheme.body1),
              SizedBox(width: 12),
              FlatButton(
                color: Colors.pinkAccent,
                child: Text('POP'),
                onPressed: () => Navigator.of(context).pop('dog page pop!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
