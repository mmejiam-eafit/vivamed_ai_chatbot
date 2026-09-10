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
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
    });

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: const OnboardingTemplate(carousel: SizedBox()),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
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

    // ── Content width (DT §9.5) ────────────────────────────────────────────

    Finder find560Cap() => find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 560,
          description: 'ConstrainedBox capped at 560',
        );

    testWidgets('compact: carousel is not width-capped', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.mediumMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: Text('carousel')),
        ),
      );
      expect(find560Cap(), findsNothing);
    });

    testWidgets('medium and up: carousel is capped at 560', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const OnboardingTemplate(carousel: Text('carousel')),
        ),
      );
      expect(find560Cap(), findsOneWidget);
    });
  });
}
