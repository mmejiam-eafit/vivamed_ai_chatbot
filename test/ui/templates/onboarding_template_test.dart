import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';

void main() {
  group('OnboardingTemplate', () {
    testWidgets('renders carousel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: Text('carousel')),
        ),
      );
      expect(find.text('carousel'), findsOneWidget);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: SizedBox()),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.surfacePage);
    });

    testWidgets('wraps carousel in SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: Text('inside')),
        ),
      );
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('no app bar is rendered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: SizedBox()),
        ),
      );
      expect(find.byType(AppBar), findsNothing);
    });
  });
}
