import 'package:flutter/material.dart';
import './pages/splashscreen.dart';
import './pages/login_page.dart';
import './pages/dashboard_page.dart';
import './pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const AnimatedSplashScreen(),
        "/login": (context) => const LoginPage(),
        "/home": (context) => const DashboardPage(),
        "/profile": (context) => const ProfilePage(),
      },
    );
  }
}