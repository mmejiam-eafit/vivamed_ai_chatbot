import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/pages/home_hub_page.dart';
import 'package:radiologist_helper/ui/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ThemeController> controllerWith(ThemeMode mode) async {
    SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
    return ThemeController.load();
  }

  group('App', () {
    testWidgets('resolves MaterialApp.themeMode from the controller',
        (tester) async {
      final controller = await controllerWith(ThemeMode.light);
      await tester.pumpWidget(App(themeController: controller));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });

    testWidgets('changing the controller updates MaterialApp.themeMode',
        (tester) async {
      final controller = await controllerWith(ThemeMode.dark);
      await tester.pumpWidget(App(themeController: controller));
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );

      controller.setMode(ThemeMode.light);
      await tester.pump();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );
    });

    // ── Post-sign-in navigation ──────────────────────────────────────────

    testWidgets('first sign-in (onboarding not completed) goes to Onboarding',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();
      await tester.pumpWidget(
        ProviderScope(child: App(themeController: controller)),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingPage), findsOneWidget);
    });

    testWidgets('returning sign-in (onboarding completed) goes to Home Hub',
        (tester) async {
      SharedPreferences.setMockInitialValues(
        {'has_completed_onboarding': true},
      );
      final controller = await ThemeController.load();
      await tester.pumpWidget(
        ProviderScope(child: App(themeController: controller)),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.byType(HomeHubPage), findsOneWidget);
    });

    testWidgets('completing onboarding goes to Home Hub', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();
      await tester.pumpWidget(
        ProviderScope(child: App(themeController: controller)),
      );

      await tester.tap(find.byType(AppButton)); // Sign In -> Onboarding
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingPage), findsOneWidget);

      // Walk the carousel to its last slide (label flips to "Get Started"),
      // regardless of how many slides mockOnboardingSlides has.
      while (tester.widget<AppButton>(find.byType(AppButton)).label !=
          'Get Started') {
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(find.byType(HomeHubPage), findsOneWidget);
    });
  });
}
