import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   'assets/MegafonitoJPEG.jpeg',
            //   width: 200,
            //   height: 200,
            // ),
            SizedBox(height: 20),
            SvgPicture.asset(
              'assets/Megafonito.svg',
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 34, 32, 78),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 20,
                backgroundColor: Color(0xFFE5E5E5),
                color: Color.fromARGB(255, 34, 32, 78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
