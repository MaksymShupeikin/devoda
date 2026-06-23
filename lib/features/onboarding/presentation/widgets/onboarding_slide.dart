import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A single intro slide: a large illustrative icon, a title and a description.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.imagePath,
    required this.accent,
    required this.title,
    required this.description,
  });

  final String imagePath;
  final Color accent;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                imagePath,
                width: 248,
                height: 248,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.display.copyWith(fontSize: 30),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
