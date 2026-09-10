import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';

class OnboardingTemplate extends StatelessWidget {
  const OnboardingTemplate({super.key, required this.carousel});

  final Widget carousel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Medium: cap content width, matching every other single-column
            // page at this tier (DT §9.5). Expanded/ultrawide's own spec —
            // image left, copy right — needs OnboardingCarousel to accept a
            // layout mode it doesn't have yet; deferred (gap 17), not built
            // here as a half version of it.
            final isCompact =
                constraints.maxWidth.layoutTier == AppLayoutTier.compact;
            return isCompact
                ? carousel
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: carousel,
                    ),
                  );
          },
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewSlides = [
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/xray1/600/400',
    title: 'AI-Powered Analysis',
    description:
        'Our model reviews your DICOM studies and highlights potential findings instantly.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/xray2/600/400',
    title: 'Ask Anything',
    description:
        'Chat with the AI to get explanations, differential diagnoses, and follow-up suggestions.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/xray3/600/400',
    title: 'Review with Confidence',
    description:
        'Cross-reference similar cases and patient history to support your final report.',
  ),
];

@Preview(name: 'first slide', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewOnboardingFirst() => OnboardingTemplate(
      carousel: OnboardingCarousel(
        slides: _previewSlides,
        onComplete: () {},
      ),
    );

@Preview(name: 'last slide', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewOnboardingLast() => OnboardingTemplate(
      carousel: OnboardingCarousel(
        slides: _previewSlides,
        onComplete: () {},
        initialPage: 2,
      ),
    );
