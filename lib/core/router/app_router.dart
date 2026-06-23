import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/onboarding/controllers/onboarding_controller.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

/// Global router. Routes are declared on the pages themselves; this file just
/// lists them and guards the onboarding flow.
final goRouterProvider = Provider<GoRouter>((ref) {
  final seenOnboarding = ref.read(onboardingControllerProvider);

  return GoRouter(
    initialLocation: seenOnboarding ? MapPage.path : OnboardingPage.path,
    routes: [OnboardingPage.route, MapPage.route, LoginPage.route],
    redirect: (context, state) {
      final seen = ref.read(onboardingControllerProvider);
      final atOnboarding = state.matchedLocation == OnboardingPage.path;
      if (!seen && !atOnboarding) return OnboardingPage.path;
      if (seen && atOnboarding) return MapPage.path;
      return null;
    },
  );
});
