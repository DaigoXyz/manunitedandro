import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  Future<void> _navigateToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60), // turun 20px dari sebelumnya
            // Title + Lucide icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Redsphare',
                  style: TextStyle(
                    fontSize: 34, // sedikit lebih besar biar Figma look
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => _navigateToLogin(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10, right: 0),
                    child: const Icon(
                      LucideIcons.externalLink,
                      color: const Color(0xFF991B1B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16), // tulisan turun sedikit

            const Text(
              'Where Passion Meets Style, Wear the Legacy,\nLive the Glory.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF991B1B),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 50), // turun lagi sedikit

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: ClipRRect(
                      child: Image.asset(
                        'assets/images/playerwelcome.png',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}