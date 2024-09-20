import 'package:drawing_board/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final pages = [
    PageModel(
        color: const Color(0xFF001f3f),
        imageAssetPath: 'assets/images/ic_brush.png',
        title: 'Welcome to Scribble',
        body: 'Draw and create with easy-to-use tools',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF4B0082),
        imageAssetPath: 'assets/images/ic_share.png',
        title: 'Share Your Art',
        body: 'Send your drawings to friends with just a tap',
        doAnimateImage: true),
    PageModel(
        color: const Color(0xFF36454F),
        imageAssetPath: 'assets/images/ic_start.png',
        title: "Let's Start!",
        body: 'Begin your drawing journey now',
        doAnimateImage: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverBoard(
        pages: pages,
        showBullets: true,
        skipCallback: () {
          // WRITE SKIP BUTTON ACTION HERE
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage(title: "Scribble")),
          );
        },
        finishCallback: () {
          // WRITE THE FINISH BUTTON ACTION HERE
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage(title: "Scribble")),
          );
        },
      ),
    );
  }
}
