import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/login_page.dart';
import 'package:radiologist_helper/ui/templates/auth_template.dart';

void main() {
  group('LoginPage', () {
    testWidgets('renders AuthTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      expect(find.byType(AuthTemplate), findsOneWidget);
    });

    testWidgets('renders exactly one AppButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('renders Sign In label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('renders two AppTextField widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      expect(find.byType(AppTextField), findsNWidgets(2));
    });

    testWidgets('email field uses email keyboard type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      final fields = tester.widgetList<AppTextField>(find.byType(AppTextField));
      expect(
        fields.any((f) => f.keyboardType == TextInputType.emailAddress),
        isTrue,
      );
    });

    testWidgets('password field is obscured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      final fields = tester.widgetList<AppTextField>(find.byType(AppTextField));
      expect(fields.any((f) => f.obscureText), isTrue);
    });

    testWidgets('only one AuthTemplate is instantiated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const LoginPage()),
      );

      expect(find.byType(AuthTemplate), findsOneWidget);
    });
  });
}
