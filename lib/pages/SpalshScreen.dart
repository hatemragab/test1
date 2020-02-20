import 'package:flutter/material.dart';
import 'package:test1/pages/NewLogonAndRgister/NewLogin.dart';
class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    new Future.delayed( const Duration(milliseconds: 3700), () =>
        Navigator.push( context,
          MaterialPageRoute(builder: (context) => NewLogin()),
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/splash.gif"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}