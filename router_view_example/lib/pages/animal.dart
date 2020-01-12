import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/ajanuw_router_view.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

class Animal extends StatefulWidget {
  @override
  _AnimalState createState() => _AnimalState();
}

class _AnimalState extends State<Animal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animal'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.grey,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Text('dogs'),
                      onPressed: () {
                        ajanuwRouter.pushNamed("dogs", view: true);
                      },
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      child: Text('cats'),
                      onPressed: () {
                        ajanuwRouter.pushNamed("cats", view: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: AjanuwRouterView(),
          ),
        ],
      ),
    );
  }
}
