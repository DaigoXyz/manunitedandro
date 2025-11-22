import 'package:flutter/material.dart';
import './pages/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 RESET isFirstTime (sementara untuk testing)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isFirstTime', true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AnimatedSplashScreen(),
    );
  }
}
