import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// PieCrew's mark: a pie viewed from above with one wedge cut and lifted —
/// the "crew" idea (a slice pulled out, ready to hand off) rendered as a
/// simple painted glyph instead of a stock pizza-slice icon.
class PieMark extends StatelessWidget {
  final double size;
  const PieMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PieMarkPainter()),
    );
  }
}

class _PieMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final basePaint = Paint()..color = PieCrewColors.pie;
    final crustPaint = Paint()
      ..color = PieCrewColors.crust
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09;

    // The cut wedge is rotated slightly open, like it's been pulled free.
    const wedgeStart = -math.pi / 2 - 0.18;
    const wedgeSweep = math.pi / 4;

    // Main pie body, minus the wedge.
    final bodyPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius * 0.92),
          wedgeStart + wedgeSweep, 2 * math.pi - wedgeSweep, false)
      ..close();
    canvas.drawPath(bodyPath, basePaint);
    canvas.drawCircle(center, radius * 0.92, crustPaint);

    // The lifted wedge, offset outward along its own bisector.
    final wedgeMid = wedgeStart + wedgeSweep / 2;
    final lift = Offset(math.cos(wedgeMid), math.sin(wedgeMid)) * (radius * 0.16);
    final wedgeCenter = center + lift;
    final wedgePaint = Paint()..color = PieCrewColors.pieDark;
    final wedgePath = Path()
      ..moveTo(wedgeCenter.dx, wedgeCenter.dy)
      ..arcTo(Rect.fromCircle(center: wedgeCenter, radius: radius * 0.9), wedgeStart, wedgeSweep, false)
      ..close();
    canvas.drawPath(wedgePath, wedgePaint);
    canvas.drawArc(Rect.fromCircle(center: wedgeCenter, radius: radius * 0.9), wedgeStart, wedgeSweep,
        false, crustPaint);

    // A few pepperoni dots for warmth, kept off the wedge cut line.
    final topping = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final dots = [
      center + const Offset(-6, 8),
      center + const Offset(4, 14),
      center + const Offset(-10, 2),
    ];
    for (final d in dots) {
      canvas.drawCircle(d, radius * 0.09, topping);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
