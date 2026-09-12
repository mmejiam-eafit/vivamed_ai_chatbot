import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/onboarding.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const slides = [
    OnboardingSlide(
      imageUrl: 'https://example.com/img.png',
      title: 'A Title',
      description: 'A description of this onboarding slide.',
    ),
  ];

  testWidgets('renders the first slide title and description',
      (tester) async {
    await tester.pumpWidget(wrap(
      OnboardingCarousel(slides: slides, onComplete: () {}),
    ));
    expect(find.text('A Title'), findsOneWidget);
    expect(
      find.text('A description of this onboarding slide.'),
      findsOneWidget,
    );
  });

  // ── Text scale (DL §8.6, DT §3.7 — gap 9) ─────────────────────────────

  testWidgets('slide content sits in a scroll view, not a bare Column',
      (tester) async {
    await tester.pumpWidget(wrap(
      OnboardingCarousel(slides: slides, onComplete: () {}),
    ));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('does not overflow at 200% text scale', (tester) async {
    await tester.pumpWidget(wrap(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 640),
          textScaler: TextScaler.linear(2.0),
        ),
        child: OnboardingCarousel(slides: slides, onComplete: () {}),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: Scaffold(
        body: OnboardingCarousel(slides: slides, onComplete: () {}),
      ),
    ));
    final title = tester.widget<Text>(find.text('A Title'));
    expect(title.style?.color, AppColorsData.dark.textPrimary);
  });
}
