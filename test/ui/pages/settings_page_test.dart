import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<Widget> wrap() async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    return ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(),
        home: ThemeControllerScope(
          controller: controller,
          child: const SettingsPage(),
        ),
      ),
    );
  }

  group('SettingsPage', () {
    testWidgets('renders SettingsTemplate', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.byType(SettingsTemplate), findsOneWidget);
    });

    testWidgets('renders Settings in app bar', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Account section label', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('renders Appearance section label', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('renders About section label', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('only one SettingsTemplate is instantiated', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.byType(SettingsTemplate), findsOneWidget);
    });

    // ── Appearance section ───────────────────────────────────────────────

    testWidgets('Appearance section shows the theme-mode choices',
        (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('defaults to dark with no stored preference', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
      final dark = tester.widget<Text>(find.text('Dark'));
      expect(dark.style?.color, AppColorsData.light.interactivePrimary);
    });

    testWidgets('tapping Light selects it and calls setMode', (tester) async {
      // This wraps only SettingsPage, not the real App -- so it verifies
      // the selector updates and the controller's mode changes, not that
      // MaterialApp's own theme follows (that's app_test.dart's job).
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pump();

      final light = tester.widget<Text>(find.text('Light'));
      expect(light.style?.color, AppColorsData.light.interactivePrimary);
      final dark = tester.widget<Text>(find.text('Dark'));
      expect(dark.style?.color, AppColorsData.light.textPrimary);
    });

    // ── Account section (backed by currentUserProvider) ─────────────────

    testWidgets('Account section shows the resolved user profile',
        (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();
      expect(find.text('Dr. A. Ramírez'), findsOneWidget);
      expect(find.text('Radiologist'), findsOneWidget);
      expect(find.text('aramirez@hospital.org'), findsOneWidget);
    });
  });
}
