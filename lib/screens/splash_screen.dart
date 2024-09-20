import 'package:drawing_board/screens/home_page.dart';
import 'package:drawing_board/screens/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.elasticOut);
    _controller!.forward();

    Future.delayed(const Duration(seconds: 2), () {
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (_) => const HomePage(title: "Scribble")),
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const IntroductionScreen()),
      );
    },);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RotationTransition(
        turns: _animation!,
        child: Center(
          child: Image.asset("assets/images/ic_logo.png", width: 120, height: 120,)
        ),
      ),
    );
  }
}

