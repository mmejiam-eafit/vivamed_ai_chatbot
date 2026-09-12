import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/onboarding.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    required this.slides,
    required this.onComplete,
    this.initialPage = 0,
  });

  final List<OnboardingSlide> slides;
  final VoidCallback onComplete;
  final int initialPage;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_currentPage < widget.slides.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.transition,
        curve: AppMotion.enter,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == widget.slides.length - 1;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) =>
                _SlidePage(slide: widget.slides[index]),
          ),
        ),
        _buildDots(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: SizedBox(
            width: double.infinity,
            child: AppButton(
              label: isLast ? 'Get Started' : 'Next',
              onPressed: _advance,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDots() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.slides.length, (i) {
          final isActive = i == _currentPage;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
            width: isActive ? 20.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderInput,
              color: isActive ? colors.interactivePrimary : colors.borderSubdued,
            ),
          );
        }),
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      // A LayoutBuilder + scroll view, not a plain Column: at 200% text scale
      // the title and description need somewhere to grow into, and a fixed
      // 240px image left them none (DL §8.6, DT §3.7).
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppImage(
                  url: slide.imageUrl,
                  height: 240,
                  width: double.infinity,
                  borderRadius: AppRadius.borderCard,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppText(
                  slide.title,
                  style: AppTypography.displaySm,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  slide.description,
                  style: AppTypography.bodyMd,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewSlides = [
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/400/240?random=1',
    title: 'AI-Assisted Radiology',
    description: 'Chat with an AI to analyze X-rays, CT scans, and MRIs in real time.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/400/240?random=2',
    title: 'Instant Findings',
    description: 'Critical findings are highlighted automatically so you can act fast.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/400/240?random=3',
    title: 'Ready When You Are',
    description: 'Your conversation history and reports are always one tap away.',
  ),
];

@Preview(name: 'first slide', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewOnboardingCarouselFirst() =>
    OnboardingCarousel(slides: _previewSlides, onComplete: () {});

@Preview(name: 'last slide', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewOnboardingCarouselLast() => OnboardingCarousel(
      slides: _previewSlides,
      onComplete: () {},
      initialPage: _previewSlides.length - 1,
    );
