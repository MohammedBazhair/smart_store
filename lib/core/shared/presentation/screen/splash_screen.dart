import 'package:flutter/material.dart';
import '../widgets/loading/three_dots_loading.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              width: 290,
              height: 290,
            ),
            const ThreeDotsLoading(),
          ],
        ),
      ),
    );
  }
}
