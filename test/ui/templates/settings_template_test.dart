import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

void main() {
  group('SettingsTemplate', () {
    testWidgets('renders all section slots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: const [
              Text('section-a'),
              Text('section-b'),
              Text('section-c')
            ],
          ),
        ),
      );
      expect(find.text('section-a'), findsOneWidget);
      expect(find.text('section-b'), findsOneWidget);
      expect(find.text('section-c'), findsOneWidget);
    });

    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(title: const Text('Settings')),
            sections: const [],
          ),
        ),
      );
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(appBar: AppBar(), sections: const []),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.surfacePage);
    });

    testWidgets('renders empty sections without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(appBar: AppBar(), sections: const []),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses ListView for sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: const [Text('a')],
          ),
        ),
      );
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('applies list padding and section separator spacing',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: const [Text('a'), Text('b')],
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final insets = listView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.right, AppSpacing.lg);
      expect(insets.top, AppSpacing.xl);
      expect(insets.bottom, AppSpacing.xl);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == AppSpacing.xxl,
        ),
        findsOneWidget,
      );
    });
  });
}
