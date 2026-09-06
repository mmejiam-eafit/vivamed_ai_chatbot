import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/auth_template.dart';

void main() {
  group('AuthTemplate', () {
    testWidgets('renders formContent slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AuthTemplate(formContent: Text('form')),
        ),
      );
      expect(find.text('form'), findsOneWidget);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AuthTemplate(formContent: SizedBox()),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.surfacePage);
    });

    testWidgets('card is constrained to panelMaxWidth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AuthTemplate(formContent: SizedBox()),
        ),
      );
      // Find the ConstrainedBox that is a direct child of SingleChildScrollView —
      // that is our card constraint, not a framework-injected one.
      final box = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(box.constraints.maxWidth, AppLayout.panelMaxWidth);
    });

    testWidgets('card uses overlay elevation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AuthTemplate(formContent: SizedBox()),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
            of: find.byType(AuthTemplate), matching: find.byType(Container)),
      );
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.boxShadow, AppElevation.overlay);
    });

    testWidgets('applies template spacing contract', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const AuthTemplate(formContent: SizedBox()),
        ),
      );

      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      final scrollPadding = scrollView.padding! as EdgeInsets;
      expect(scrollPadding.left, AppSpacing.xl);
      expect(scrollPadding.top, AppSpacing.xl);

      final container = tester.widget<Container>(
        find.descendant(
            of: find.byType(AuthTemplate), matching: find.byType(Container)),
      );
      final cardPadding = container.padding! as EdgeInsets;
      expect(cardPadding.left, AppSpacing.xl);
      expect(cardPadding.top, AppSpacing.xl);
    });
  });
}
