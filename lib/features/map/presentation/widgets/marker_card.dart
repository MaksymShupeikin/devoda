import 'package:flutter/material.dart';

/// The on-map marker, designed as a small "card" with a colored icon badge and
/// a pointer tail. It is rendered off-screen into a bitmap (see
/// [WidgetToImage]) and registered as a Mapbox style image, so the map can draw
/// thousands of them cheaply.
///
/// [icon] is supplied by the caller (the rasterized category SVG), keeping this
/// widget free of any category logic.
class MarkerCard extends StatelessWidget {
  const MarkerCard({super.key, required this.color, required this.icon});

  final Color color;
  final Widget icon;

  /// Logical size of the rendered marker. Height == card (52) + tail (12) so
  /// the tail tip lands exactly at the image bottom (IconAnchor.BOTTOM).
  static const double width = 60;
  static const double height = 64;

  /// Size of the icon drawn inside the card.
  static const double iconSize = 30;
  static const double _tailHeight = 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Card body.
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.30),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          // Pointer tail.
          CustomPaint(
            size: const Size(18, _tailHeight),
            painter: _TailPainter(color: color),
          ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TailPainter oldDelegate) =>
      oldDelegate.color != color;
}
