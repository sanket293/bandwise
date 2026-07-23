import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../home/home_shell.dart';

/// Branded launch screen shown on every app start, matching the launcher icon:
/// on a deep-blue field, the colourful band gauge draws in and its needle
/// sweeps up to 7.5, then the name fades in with the pink "Calculator" pill.
/// Lively but brief (~1.4s), then hands off to the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Brand colours.
  static const _tealHi = Color(0xFF3A9C9C);
  static const _tealLo = Color(0xFF1C5456);
  static const _pink = Color(0xFFE91E4F);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..forward();

    // Hold after the animation, then hand off (~3s total on screen).
    Future.delayed(const Duration(milliseconds: 3000), () {
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
              // Band gauge: coloured arc draws in, needle sweeps up to 7.5.
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(220, 132),
                    painter: _GaugePainter(
                      arc: _curve(0.0, 0.55, Curves.easeOut).value,
                      needle: _curve(0.15, 0.9, Curves.easeOutCubic).value,
                      value: _curve(0.55, 1.0, Curves.easeOut).value,
                      ink: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _curve(0.6, 1.0, Curves.easeOut),
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
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _curve(0.72, 1.0, Curves.easeOut),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: _pink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CALCULATOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
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

/// A semicircular band gauge — a rainbow arc (red→blue, matching the icon) that
/// sweeps in, with a needle that settles on 7.5 and the value counting up in the
/// centre. Mirrors the "Overall Band" dial on the launcher icon.
class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.arc,
    required this.needle,
    required this.value,
    required this.ink,
  });

  /// 0→1: how much of the coloured arc has drawn in.
  final double arc;

  /// 0→1: needle progress toward its resting band.
  final double needle;

  /// 0→1: fade/scale-in of the centre value.
  final double value;

  /// Colour for the needle, hub and centre text (readable on the background).
  final Color ink;

  // Icon's arc: red → orange → yellow → green → teal → blue.
  static const _segments = [
    Color(0xFFE63946),
    Color(0xFFF4801F),
    Color(0xFFF4C020),
    Color(0xFF7CC142),
    Color(0xFF2BB673),
    Color(0xFF2196D6),
  ];
  static const _restFrac = 7.5 / 9; // needle settles at band 7.5

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const stroke = 20.0;
    const start = math.pi; // left end
    const sweep = math.pi; // half turn to the right

    // Coloured arc, revealed left→right.
    final rect = Rect.fromCircle(center: center, radius: radius);
    final drawn = sweep * arc.clamp(0.0, 1.0);
    final segSweep = sweep / _segments.length;
    for (int i = 0; i < _segments.length; i++) {
      final segStart = start + segSweep * i;
      final visible = (start + drawn) - segStart;
      if (visible <= 0) break;
      final thisSweep = math.min(segSweep, visible);
      canvas.drawArc(
        rect,
        segStart,
        thisSweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..color = _segments[i],
      );
    }

    // Needle sweeping to 7.5 (drawn under the centre value so text stays clear).
    final angle = start + sweep * _restFrac * needle.clamp(0.0, 1.0);
    final tip = Offset(
      center.dx + math.cos(angle) * (radius - 4),
      center.dy + math.sin(angle) * (radius - 4),
    );
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = ink
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(center, 9, Paint()..color = ink);
    canvas.drawCircle(center, 4.5, Paint()..color = _segments.last);

    // Centre value "7.5" + "Overall Band", scaling/fading in on top.
    if (value > 0.01) {
      final v = value.clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(center.dx, center.dy - radius * 0.42);
      canvas.scale(0.85 + 0.15 * v);
      final num = TextPainter(
        text: TextSpan(
          text: '7.5',
          style: TextStyle(
            color: ink.withValues(alpha: v),
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      num.paint(canvas, Offset(-num.width / 2, -num.height / 2));
      final label = TextPainter(
        text: TextSpan(
          text: 'Overall Band',
          style: TextStyle(
            color: ink.withValues(alpha: v * 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(-label.width / 2, num.height / 2 + 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.arc != arc ||
      old.needle != needle ||
      old.value != value ||
      old.ink != ink;
}
