import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/point_category.dart';

/// Renders a water category's custom SVG icon, tinted with [color].
///
/// Used everywhere on-screen (filter chips, add/details sheets). The same SVGs
/// are baked into the map markers, so icons stay consistent across the app.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    required this.size,
    required this.color,
  });

  final PointCategory category;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      category.svgAsset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      // Show the Material fallback glyph until the SVG is parsed.
      placeholderBuilder: (_) => Icon(category.icon, size: size, color: color),
    );
  }
}
