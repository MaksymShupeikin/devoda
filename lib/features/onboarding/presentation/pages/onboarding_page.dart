import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../controllers/onboarding_controller.dart';
import '../widgets/onboarding_slide.dart';

/// First-run intro that explains the app with simple visuals and large text.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  static const String path = '/onboarding';
  static const String name = 'onboarding';

  static GoRoute get route => GoRoute(
    path: path,
    name: name,
    builder: (context, state) => const OnboardingPage(),
  );

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const int _slideCount = 3;

  List<OnboardingSlide> _buildSlides(AppLocalizations l) => [
    OnboardingSlide(
      imagePath: 'assets/onboarding/onboarding_1.png',
      accent: AppColors.categoryDrinkingWater,
      title: l.onb1Title,
      description: l.onb1Desc,
    ),
    OnboardingSlide(
      imagePath: 'assets/onboarding/onboarding_2.png',
      accent: AppColors.categoryWaterPoint,
      title: l.onb2Title,
      description: l.onb2Desc,
    ),
    OnboardingSlide(
      imagePath: 'assets/onboarding/onboarding_3.png',
      accent: AppColors.categoryResilience,
      title: l.onb3Title,
      description: l.onb3Desc,
    ),
  ];

  bool get _isLast => _index == _slideCount - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (!mounted) return;
    context.goNamed(MapPage.name);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = _buildSlides(l10n);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: _isLast
                    ? const SizedBox(height: 48)
                    : TextButton(
                        onPressed: _finish,
                        child: Text(
                          l10n.onbSkip,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => slides[i],
              ),
            ),
            const SizedBox(height: 12),
            _Dots(count: slides.length, active: _index),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: AppButton(
                label: _isLast ? l10n.onbStart : l10n.onbNext,
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 28 : 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }
}
