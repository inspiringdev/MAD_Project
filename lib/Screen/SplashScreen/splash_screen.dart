import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/theme/style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  Animation? animation, delayedAnimation, muchDelayAnimation, transfor, fadeAnimation;
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation = Tween(begin: 0.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Curves.fastOutSlowIn
    ));

    transfor = BorderRadiusTween(
        begin: BorderRadius.circular(125.0),
        end: BorderRadius.circular(0.0)).animate(
        CurvedAnimation(parent: animationController!, curve: Curves.ease)
    );
    fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animationController!);
    animationController!.forward();

    Timer(Duration(seconds: 3), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;  // New flag
      bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

      if (!isLoggedIn) {
        // ALWAYS show login screen first if not logged in
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.loginScreen, (Route<dynamic> route) => false);
      } else {
        // User is logged in
        if (!hasSeenIntro) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.introScreen, (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.homeScreen, (Route<dynamic> route) => false);
        }
      }
    });

  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext? context, Widget? child) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Your splash UI here
                ],
              ),
            ),
          );
        }
    );
  }
}
