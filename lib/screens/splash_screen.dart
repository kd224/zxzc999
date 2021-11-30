import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zxzc9992/services/auth/auth.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    final res = await Auth().isAuthenticated();
    print(res);
    if (res == false) {
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    if (res == true) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Splash screen
    return const Scaffold(
      body: CircularProgressIndicator(),
    );
  }
}
