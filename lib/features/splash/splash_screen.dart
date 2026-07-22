import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../home/home_shell.dart';

/// Branded launch screen shown on every app start: the BandWise mark animates in
/// (bars rise, marker pops, name fades) before handing off to the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    // Hand off to the app shortly after the animation completes.
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF17C3B2), // teal
              Color(0xFF2E78BE), // blue
              Color(0xFF4338CA), // indigo
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(140, 128),
                    painter: _MarkPainter(_c.value),
                  );
                },
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: _c, curve: const Interval(0.5, 1.0)),
                child: const Text(
                  'BandWise',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FadeTransition(
                opacity: CurvedAnimation(
                    parent: _c, curve: const Interval(0.65, 1.0)),
                child: Text(
                  'Know your band',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
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

/// Paints the four ascending bars (rising as [t] goes 0→1) with a marker dot
/// that pops in near the end.
class _MarkPainter extends CustomPainter {
  _MarkPainter(this.t);
  final double t;

  static const _heights = [0.42, 0.60, 0.78, 1.0];

  double _eased(double x) => Curves.easeOutCubic.transform(x.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final n = 4;
    const gap = 0.075;
    final markW = size.width;
    final markH = size.height;
    final bw = (markW - markW * gap * (n - 1)) / n;
    final bottom = size.height;

    final barPaint = Paint()..color = Colors.white;
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.28);

    double tallestCx = 0, tallestTop = 0;
    for (int i = 0; i < n; i++) {
      // Staggered growth per bar.
      final start = i * 0.12;
      final local = ((t - start) / 0.55).clamp(0.0, 1.0);
      final grown = _eased(local);
      final fullH = markH * _heights[i];
      final h = fullH * grown;
      if (h <= 0.5) continue;
      final left = i * (bw + markW * gap);
      final top = bottom - h;
      final rect = RRect.fromLTRBR(
          left, top, left + bw, bottom, Radius.circular(bw / 2));
      canvas.drawRRect(rect, barPaint);
      // top sheen
      final sheen = RRect.fromLTRBR(
          left, top, left + bw, top + math.min(h * 0.3, bw), Radius.circular(bw / 2));
      canvas.drawRRect(sheen, highlight);
      if (i == n - 1) {
        tallestCx = left + bw / 2;
        tallestTop = top;
      }
    }

    // Marker pops in over the last part of the animation.
    final mk = _eased(((t - 0.65) / 0.35).clamp(0.0, 1.0));
    if (mk > 0 && tallestCx > 0) {
      final r = bw * 0.78 * mk;
      final center = Offset(tallestCx, tallestTop);
      canvas.drawCircle(center, r * 1.18, Paint()..color = Colors.white);
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFBBF24));
      canvas.drawCircle(
        Offset(center.dx - r * 0.28, center.dy - r * 0.3),
        r * 0.26,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.t != t;
}
