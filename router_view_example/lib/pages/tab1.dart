import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

class Tab1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Tab1 work.'),
          RaisedButton(
           child: Text('to Animal'),
           onPressed: () {
             ajanuwRouter.pushNamed('/animal');
           },
          ),
        ],
      ),
    );
  }
}
