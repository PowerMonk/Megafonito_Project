import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Megafonito',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
        ),
        primaryColor: Color(0xFF14213D),
        scaffoldBackgroundColor: Color(0xFF14213D),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF000000)),
        ),
      ),
      home: SplashScreen(),
    );
  }
}
