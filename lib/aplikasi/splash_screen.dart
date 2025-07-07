import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/welcome_screen.dart';
import 'package:projectabsen/utils/shared_prefences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    changePage();
  }

  void changePage() async {
    await Future.delayed(Duration(seconds: 3));
    bool isLogin = await PreferenceHandler.getLogin();
    print("isLogin: $isLogin");
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/image/splash.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Text(
                  "v 4.0.0",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
