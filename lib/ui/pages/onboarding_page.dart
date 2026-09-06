import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';

const _slides = [
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob1/400/240',
    title: 'AI-Powered Analysis',
    description: 'Analyze DICOM studies with AI assistance.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob2/400/240',
    title: 'Ask Anything',
    description: 'Chat with the AI radiologist assistant.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob3/400/240',
    title: 'Review with Confidence',
    description: 'Confident reporting backed by AI findings.',
  ),
];

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingTemplate(
      carousel: OnboardingCarousel(
        slides: _slides,
        onComplete: () {},
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'onboarding', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewOnboardingPage() => const OnboardingPage();
