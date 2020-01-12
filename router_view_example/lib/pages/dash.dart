import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/ajanuw_router_view.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';

class Dash extends StatefulWidget {
  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      ajanuwRouter.pushNamed("tab1", view: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                        child: Text('Tab1'),
                        onPressed: () {
                          ajanuwRouter.pushNamed("tab1", view: true);
                        },
                      ),
                    ),
                    Expanded(
                      child: FlatButton(
                        child: Text('Tab2'),
                        onPressed: () {
                          ajanuwRouter.pushNamed("tab2", view: true);
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
      ),
    );
  }
}
