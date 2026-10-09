import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/section_index_tile.dart';
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
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
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

    group('expanded and up (>= threePaneMinWidth)', () {
      Future<void> pumpExpanded(
        WidgetTester tester, {
        int selectedIndex = 0,
        ValueChanged<int>? onSectionSelected,
      }) async {
        tester.view.physicalSize =
            const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
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

      testWidgets('shows every title and every section\'s content at once',
          (tester) async {
        await pumpExpanded(tester);
        // Each title appears twice: once in the index rail, once as its own
        // SectionCard's heading -- all three sections render together now,
        // not just the selected one (Settings should keep a continuous feel,
        // not three separate pages).
        expect(find.text('Account'), findsNWidgets(2));
        expect(find.text('Display'), findsNWidgets(2));
        expect(find.text('About'), findsNWidgets(2));
        expect(find.text('account-content'), findsOneWidget);
        expect(find.text('display-content'), findsOneWidget);
        expect(find.text('about-content'), findsOneWidget);
      });

      testWidgets('selectedIndex controls which index tile is highlighted',
          (tester) async {
        await pumpExpanded(tester, selectedIndex: 1);
        final tiles =
            tester.widgetList<SectionIndexTile>(find.byType(SectionIndexTile));
        expect(tiles.firstWhere((t) => t.title == 'Display').isSelected, isTrue);
        expect(tiles.firstWhere((t) => t.title == 'Account').isSelected, isFalse);
        expect(tiles.firstWhere((t) => t.title == 'About').isSelected, isFalse);
        // Still all present -- selection only changes the highlight now.
        expect(find.text('account-content'), findsOneWidget);
        expect(find.text('display-content'), findsOneWidget);
      });

      testWidgets('index is 200 wide', (tester) async {
        await pumpExpanded(tester);
        expect(
          find.byWidgetPredicate((w) => w is SizedBox && w.width == 200.0),
          findsOneWidget,
        );
      });

      testWidgets('tapping an index title calls onSectionSelected', (tester) async {
        // 'Display' now appears twice (rail + its own SectionCard heading,
        // since all sections render) -- target the rail tile specifically.
        int? tapped;
        await pumpExpanded(tester, onSectionSelected: (i) => tapped = i);
        await tester.tap(find.widgetWithText(SectionIndexTile, 'Display'));
        // pumpAndSettle, not pump: the tap also kicks off ensureVisible's
        // (possibly animated) scroll -- let it finish before the test ends.
        await tester.pumpAndSettle();
        expect(tapped, 1);
      });

      testWidgets('out-of-range selectedIndex clamps instead of crashing',
          (tester) async {
        await pumpExpanded(tester, selectedIndex: 99);
        expect(tester.takeException(), isNull);
        // Clamps to the last section for highlighting purposes; all three
        // still render regardless (they always do now).
        final tiles =
            tester.widgetList<SectionIndexTile>(find.byType(SectionIndexTile));
        expect(tiles.firstWhere((t) => t.title == 'About').isSelected, isTrue);
        expect(find.text('about-content'), findsOneWidget);
      });
    });

    testWidgets(
        'expandedMinWidth (below threePaneMinWidth): still single-column, '
        'each title once -- the exact gap this boundary alignment closes',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
        ),
      );
      expect(find.text('Account'), findsOneWidget);
      expect(find.byType(SectionIndexTile), findsNothing);
    });

    // ── Dark theme ─────────────────────────────────────────────────────────

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(Brightness.dark),
        home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
      ));
      final title = tester.widget<Text>(find.text('Account'));
      expect(title.style?.color, AppColorsData.dark.textPrimary);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });

    // ── navBar slot ──────────────────────────────────────────────────────

    testWidgets('navBar is passed to Scaffold.bottomNavigationBar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: threeSections,
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(find.text('nav-bar-slot'), findsOneWidget);
    });

    testWidgets('navBar is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    // ── primaryNavDrawer: expanded/ultrawide only (desktop/web revisit) ────

    testWidgets(
        'threePaneMinWidth: navBar is NOT shown even when provided -- '
        'primaryNavDrawer replaces it', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: threeSections,
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('nav-bar-slot'), findsNothing);
    });

    testWidgets(
        'threePaneMinWidth: primaryNavDrawer is wired as Scaffold.drawer, '
        'no app bar', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(title: const Text('Settings')),
            sections: threeSections,
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      // No app bar at this tier to show a DrawerButton in anymore -- the
      // menu trigger lives at the bottom of menuRail instead.
      expect(scaffold.appBar, isNull);
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('threePaneMinWidth: menuRail renders, absent below it',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: threeSections,
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      expect(find.text('menu-rail-slot'), findsOneWidget);
    });

    testWidgets(
        'expandedMinWidth (below threePaneMinWidth): still shows app bar '
        'and navBar, not primaryNavDrawer/menuRail -- the exact gap this '
        'boundary alignment closes', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(title: const Text('Settings')),
            sections: threeSections,
            navBar: const Text('nav-bar-slot'),
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(scaffold.drawer, isNull);
      expect(find.text('menu-rail-slot'), findsNothing);
    });

    testWidgets('compact/medium: menuRail is ignored', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: threeSections,
            menuRail: const Text('menu-rail-slot'),
          ),
        ),
      );
      expect(find.text('menu-rail-slot'), findsNothing);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.appBar, isNotNull);
    });

    testWidgets(
        'compact/medium: primaryNavDrawer is ignored, navBar still shows',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsTemplate(
            appBar: AppBar(),
            sections: threeSections,
            navBar: const Text('nav-bar-slot'),
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(scaffold.drawer, isNull);
      expect(find.text('primary-nav-drawer-slot'), findsNothing);
    });
  });
}
