import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/onboarding_carousel.dart';
import 'package:radiologist_helper/ui/pages/onboarding_page.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';

void main() {
  group('OnboardingPage', () {
    testWidgets('renders OnboardingTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const OnboardingPage()),
      );

      expect(find.byType(OnboardingTemplate), findsOneWidget);
    });

    testWidgets('renders OnboardingCarousel', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const OnboardingPage()),
      );

      expect(find.byType(OnboardingCarousel), findsOneWidget);
    });

    testWidgets('carousel shows Next button on first slide', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const OnboardingPage()),
      );

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('only one OnboardingTemplate is instantiated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const OnboardingPage()),
      );

      expect(find.byType(OnboardingTemplate), findsOneWidget);
    });
  });
}
