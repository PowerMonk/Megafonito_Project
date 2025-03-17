import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        progress += 0.1;
      });

      if (progress >= 1) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF14213D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/LogoMegafon_V2.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFCA311),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Color(0xFFE5E5E5),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFCA311)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
