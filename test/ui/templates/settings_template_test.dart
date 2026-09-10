import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

void main() {
  group('SettingsTemplate', () {
    const threeSections = [
      SettingsSection(title: 'Account', child: Text('account-content')),
      SettingsSection(title: 'Display', child: Text('display-content')),
      SettingsSection(title: 'About', child: Text('about-content')),
    ];

    testWidgets('renders every section title and its content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
        ),
      );
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('account-content'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);
      expect(find.text('display-content'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('about-content'), findsOneWidget);
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

    // ── Compact / medium: single column (DT §9.5) ────────────────────────────

    group('compact and medium (< expandedMinWidth)', () {
      testWidgets('uses ListView for sections', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: SettingsTemplate(
              appBar: AppBar(),
              sections: const [
                SettingsSection(title: 'A', child: Text('a')),
              ],
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
            home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
          ),
        );

        final listView = tester.widget<ListView>(find.byType(ListView));
        final insets = listView.padding! as EdgeInsets;
        expect(insets.left, AppSpacing.lg);
        expect(insets.right, AppSpacing.lg);
        expect(insets.top, AppSpacing.xl);
        expect(insets.bottom, AppSpacing.xl);

        // Two separators for three sections — at least one is the point.
        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == AppSpacing.xxl,
          ),
          findsWidgets,
        );
      });

      testWidgets('compact: content is not width-capped', (tester) async {
        tester.view.physicalSize =
            const Size((AppLayout.mediumMinWidth - 1) * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
          ),
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is ConstrainedBox && w.constraints.maxWidth == 640,
          ),
          findsNothing,
        );
      });

      testWidgets('medium: content is capped at 640', (tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
          ),
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is ConstrainedBox && w.constraints.maxWidth == 640,
          ),
          findsOneWidget,
        );
      });
    });

    // ── Expanded and up: index + content (DT §9.5) ───────────────────────────

    group('expanded and up (>= expandedMinWidth)', () {
      Future<void> pumpExpanded(
        WidgetTester tester, {
        int selectedIndex = 0,
        ValueChanged<int>? onSectionSelected,
      }) async {
        tester.view.physicalSize =
            const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: SettingsTemplate(
              appBar: AppBar(),
              sections: threeSections,
              selectedIndex: selectedIndex,
              onSectionSelected: onSectionSelected,
            ),
          ),
        );
      }

      testWidgets('shows every title in the index, but only the selected content',
          (tester) async {
        await pumpExpanded(tester);
        // Each title appears twice: once in the index, once as the selected
        // content pane's own heading (Account is selected by default).
        expect(find.text('Account'), findsNWidgets(2));
        expect(find.text('Display'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('account-content'), findsOneWidget);
        expect(find.text('display-content'), findsNothing);
        expect(find.text('about-content'), findsNothing);
      });

      testWidgets('selectedIndex controls which content shows', (tester) async {
        await pumpExpanded(tester, selectedIndex: 1);
        expect(find.text('display-content'), findsOneWidget);
        expect(find.text('account-content'), findsNothing);
      });

      testWidgets('index is 200 wide', (tester) async {
        await pumpExpanded(tester);
        expect(
          find.byWidgetPredicate((w) => w is SizedBox && w.width == 200.0),
          findsOneWidget,
        );
      });

      testWidgets('tapping an index title calls onSectionSelected', (tester) async {
        int? tapped;
        await pumpExpanded(tester, onSectionSelected: (i) => tapped = i);
        await tester.tap(find.text('Display'));
        await tester.pump();
        expect(tapped, 1);
      });

      testWidgets('out-of-range selectedIndex clamps instead of crashing',
          (tester) async {
        await pumpExpanded(tester, selectedIndex: 99);
        expect(tester.takeException(), isNull);
        expect(find.text('about-content'), findsOneWidget);
      });
    });

    // ── Dark theme ─────────────────────────────────────────────────────────

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
      ));
      final title = tester.widget<Text>(find.text('Account'));
      expect(title.style?.color, AppColorsData.dark.textPrimary);
    });
  });
}
