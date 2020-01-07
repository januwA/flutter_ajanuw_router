import 'dart:async';

import 'package:example/main.dart' show router;

class AuthService {
  AuthService() {
    _isLogin$.sink.add(islogin);
  }

  String redirectTo = '/';
  bool islogin = false;
  final _isLogin$ = StreamController<bool>();
  Stream<bool> get islogin$ => _isLogin$.stream.asBroadcastStream();

  void login() {
    islogin = true;
    _isLogin$.sink.add(islogin);
    // router.navigator.pushReplacementNamed(redirectTo);
    router.navigator.popAndPushNamed(redirectTo);
  }

  void logout() {
    islogin = false;
    _isLogin$.sink.add(islogin);
  }

  dispose() {
    _isLogin$.close();
  }
}

final AuthService authService = AuthService();
