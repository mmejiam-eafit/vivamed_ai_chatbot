import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/data/mocks/onboarding_mocks.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  Future<void> _complete(BuildContext context, WidgetRef ref) async {
    await ref.read(onboardingServiceProvider).markCompleted();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingTemplate(
      carousel: OnboardingCarousel(
        slides: mockOnboardingSlides,
        onComplete: () => _complete(context, ref),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'onboarding', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewOnboardingPage() => const OnboardingPage();
