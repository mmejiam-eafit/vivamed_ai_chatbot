import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

void main() {
  group('SettingsPage', () {
    testWidgets('renders SettingsTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.byType(SettingsTemplate), findsOneWidget);
    });

    testWidgets('renders Settings in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Account section label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('renders Display section label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.text('Display'), findsOneWidget);
    });

    testWidgets('renders About section label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('only one SettingsTemplate is instantiated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const SettingsPage()),
      );

      expect(find.byType(SettingsTemplate), findsOneWidget);
    });
  });
}
