import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/mocks/onboarding_mocks.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      carousel: OnboardingCarousel(
        slides: mockOnboardingSlides,
        onComplete: () {},
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'onboarding', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewOnboardingPage() => const OnboardingPage();
