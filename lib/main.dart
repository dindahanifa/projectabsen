import 'package:flutter/material.dart';
import 'package:projectabsen/aplikasi/user_absen.dart';
import 'package:projectabsen/aplikasi/splash_screen.dart';
import 'package:projectabsen/aplikasi/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => SplashScreen(),
        "/welcomeScreen": (context) => WelcomeScreen(),
        UserScreen.id: (context) => UserScreen()
      },
      debugShowCheckedModeBanner: false,
      title: 'Project Ketiga',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
    );
  }
}