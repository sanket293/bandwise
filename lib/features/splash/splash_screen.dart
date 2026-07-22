import 'package:flutter/material.dart';

import '../home/home_shell.dart';

/// Branded launch screen shown on every app start: the BandWise "B" monogram
/// pops in with its accent dot and the name fades up, on the app's calm teal —
/// then hands off to the app. Matches the launcher icon.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Brand colours (mirror tool/gen_branding.py + app_theme.dart).
  static const _tealHi = Color(0xFF3A9C9C);
  static const _tealLo = Color(0xFF1C5456);
  static const _green = Color(0xFF66A445);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    // Brief hold after the animation, then hand off (~1s total on screen).
    Future.delayed(const Duration(milliseconds: 650 + 350), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const HomeShell(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _curve(double begin, double end, Curve curve) =>
      CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: curve));

  @override
  Widget build(BuildContext context) {
    final markIn = _curve(0.0, 0.55, Curves.easeOutBack);
    final dotIn = _curve(0.42, 0.78, Curves.easeOutBack);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_tealHi, _tealLo],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "B" monogram with its accent dot, popping in together.
              SizedBox(
                width: 140,
                height: 132,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    return Opacity(
                      opacity: markIn.value.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: 0.7 + 0.3 * markIn.value,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            const Text(
                              'B',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 128,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 6,
                              child: Transform.scale(
                                scale: dotIn.value.clamp(0.0, 1.0),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: _green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _curve(0.45, 1.0, Curves.easeOut),
                child: const Text(
                  'IELTS Band Score',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FadeTransition(
                opacity: _curve(0.55, 1.0, Curves.easeOut),
                child: Text(
                  'Calculator',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
