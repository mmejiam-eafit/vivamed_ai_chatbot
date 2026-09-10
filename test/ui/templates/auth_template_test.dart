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
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
    });

    // ── Dark theme (gap 18) ──────────────────────────────────────────────────

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: const AuthTemplate(formContent: SizedBox()),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);

      // Medium and up renders the card; default test size already is.
      final container = tester.widget<Container>(
        find.descendant(
            of: find.byType(AuthTemplate), matching: find.byType(Container)),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, AppColorsData.dark.surface);
    });

    // ── Compact: full-bleed, no card (DT §9.5) ────────────────────────────────

    group('compact (< mediumMinWidth)', () {
      Future<void> pumpCompact(WidgetTester tester) async {
        tester.view.physicalSize =
            const Size((AppLayout.mediumMinWidth - 1) * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: const AuthTemplate(formContent: Text('form')),
          ),
        );
      }

      testWidgets('renders no card container', (tester) async {
        await pumpCompact(tester);
        expect(
          find.descendant(
              of: find.byType(AuthTemplate), matching: find.byType(Container)),
          findsNothing,
        );
      });

      testWidgets('page margin is lg, not xl', (tester) async {
        await pumpCompact(tester);
        final scrollView =
            tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
        final scrollPadding = scrollView.padding! as EdgeInsets;
        expect(scrollPadding.left, AppSpacing.lg);
        expect(scrollPadding.top, AppSpacing.lg);
      });
    });

    // ── Medium and up: centered card at formMaxWidth (DT §9.5, gap 22) ───────

    group('medium and up (>= mediumMinWidth)', () {
      Future<void> pumpMedium(WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: const AuthTemplate(formContent: SizedBox()),
          ),
        );
      }

      testWidgets('card is constrained to formMaxWidth, not panelMaxWidth',
          (tester) async {
        await pumpMedium(tester);
        // Find the ConstrainedBox that is a direct child of SingleChildScrollView —
        // that is our card constraint, not a framework-injected one.
        final box = tester.widget<ConstrainedBox>(
          find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(box.constraints.maxWidth, AppLayout.formMaxWidth);
        expect(box.constraints.maxWidth, isNot(AppLayout.panelMaxWidth));
      });

      testWidgets('card carries no shadow — it is resting content, not raised',
          (tester) async {
        await pumpMedium(tester);
        final container = tester.widget<Container>(
          find.descendant(
              of: find.byType(AuthTemplate), matching: find.byType(Container)),
        );
        expect(container.decoration, isA<BoxDecoration>());
        final decoration = container.decoration! as BoxDecoration;
        expect(decoration.boxShadow, anyOf(isNull, isEmpty));
      });

      testWidgets('applies template spacing contract', (tester) async {
        await pumpMedium(tester);

        final scrollView = tester.widget<SingleChildScrollView>(
          find.byType(SingleChildScrollView),
        );
        final scrollPadding = scrollView.padding! as EdgeInsets;
        expect(scrollPadding.left, AppSpacing.lg);
        expect(scrollPadding.top, AppSpacing.lg);

        final container = tester.widget<Container>(
          find.descendant(
              of: find.byType(AuthTemplate), matching: find.byType(Container)),
        );
        final cardPadding = container.padding! as EdgeInsets;
        expect(cardPadding.left, AppSpacing.xl);
        expect(cardPadding.top, AppSpacing.xl);
      });
    });
  });
}
