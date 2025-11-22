import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome.dart';
import 'login_page.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _transitionAnimation;

  bool hasStartedAnimation = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _transitionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Mulai animasi 500ms setelah splash muncul
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => hasStartedAnimation = true);
        _controller.forward();
      }
    });

    // 🔥 PENTING: CEK FIRST TIME USER DI SINI
    Future.delayed(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (isFirstTime) {
        // First time → ke Welcome Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      } else {
        // Bukan first time → langsung ke Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t) ?? a;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final topColor = hasStartedAnimation
            ? _lerpColor(
                const Color(0xFF999999),
                const Color(0xFF991B1B),
                _transitionAnimation.value,
              )
            : const Color(0xFF999999);

        final bottomColor = hasStartedAnimation
            ? _lerpColor(
                const Color(0xFFFFFFFF),
                const Color(0xFF330909),
                _transitionAnimation.value,
              )
            : const Color(0xFFFFFFFF);

        final showLogo1 =
            hasStartedAnimation && _transitionAnimation.value > 0.5;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
            child: Center(
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 400),
                crossFadeState: showLogo1
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Image.asset(
                  'assets/images/logo1.png',
                  width: 250,
                  height: 250,
                ),
                secondChild: Image.asset(
                  'assets/images/logo2.png',
                  width: 250,
                  height: 250,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
