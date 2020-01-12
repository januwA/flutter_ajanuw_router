import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ajanuw_router/flutter_ajanuw_router.dart';
import 'package:flutter_ajanuw_router/util/path.dart';

import 'ajanuw_routing.dart';

class AjanuwRouterView extends StatefulWidget {
  @override
  _AjanuwRouterViewState createState() => _AjanuwRouterViewState();
}

class _AjanuwRouterViewState extends State<AjanuwRouterView> {
  bool _init = true;
  Widget _h = SizedBox();
  String _path;
  String _parent;
  StreamSubscription<AjanuwRouting> listener;

  @override
  void initState() {
    super.initState();
    listener = ajanuwRouter.currentRouting$.listen((AjanuwRouting routing) {
      print("$mounted   ${routing?.path}");
      if (mounted) {
        if (routing != null) {
          if (_init) {
            setState(() {
              _h = routing.route.builder(context, routing);
              _path = routing.path;
              _parent = urlPath.dirname(routing.path);
              _init = false;
            });
          } else {
            if (_path != routing.path &&
                urlPath.isWithin(_parent, routing.path)) {
              setState(() {
                _h = routing.route.builder(context, routing);
                _path = routing.path;
              });
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    // 取消监听
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _h;
  }
}
