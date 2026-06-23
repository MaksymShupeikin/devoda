import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A custom-animated water droplet loader.
/// Shows a droplet outline with a moving wave of liquid filling it up.
class WaterDropletLoader extends StatefulWidget {
  const WaterDropletLoader({
    super.key,
    this.size = 80.0,
    this.color = AppColors.primary,
  });

  final double size;
  final Color color;

  @override
  State<WaterDropletLoader> createState() => _WaterDropletLoaderState();
}

class _WaterDropletLoaderState extends State<WaterDropletLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Animate wave phase from 0 to 2*pi, and let the fill level breathe slightly.
        final phase = _controller.value * 2 * math.pi;
        final fillLevel =
            0.55 + math.sin(_controller.value * 2 * math.pi) * 0.08;

        return CustomPaint(
          size: Size(widget.size, widget.size * 1.2),
          painter: _DropletPainter(
            color: widget.color,
            wavePhase: phase,
            fillLevel: fillLevel,
          ),
        );
      },
    );
  }
}

class _DropletPainter extends CustomPainter {
  _DropletPainter({
    required this.color,
    required this.wavePhase,
    required this.fillLevel,
  });

  final Color color;
  final double wavePhase;
  final double fillLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0);
    // Right side curve
    path.cubicTo(
      size.width * 0.85,
      size.height * 0.4,
      size.width,
      size.height * 0.65,
      size.width / 2,
      size.height,
    );
    // Left side curve
    path.cubicTo(
      0,
      size.height * 0.65,
      size.width * 0.15,
      size.height * 0.4,
      size.width / 2,
      0,
    );
    path.close();

    // 1. Draw the background filled shape (very light water tint)
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // 2. Draw the moving liquid wave (clipped inside the droplet)
    canvas.save();
    canvas.clipPath(path);

    final wavePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final wavePath = Path();
    final yBase = size.height * (1.0 - fillLevel);
    wavePath.moveTo(0, yBase);

    // Generate a smooth sine wave across the width
    const pointsCount = 40;
    for (var i = 0; i <= pointsCount; i++) {
      final x = (size.width / pointsCount) * i;
      // Combine two sine waves for more natural secondary fluid motion
      final y =
          yBase +
          math.sin((x / size.width * 2 * math.pi) - wavePhase) * 5 +
          math.cos((x / size.width * 4 * math.pi) + wavePhase) * 2;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
    canvas.restore();

    // 3. Draw the border outline
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.fillLevel != fillLevel;
  }
}
