import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'services/server_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfig.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Megafonito',
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
