import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/ajanuw_route_argument.dart';

part 'args.g.dart';

@ara
class ArgsPage extends StatefulWidget {
  final String name;
  final int id;

  const ArgsPage({Key key, this.name, this.id}) : super(key: key);
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
        child: Column(
          children: <Widget>[
            Text('ArgsPage work.'),
            Text(widget.name),
            Text(
              widget.id.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
