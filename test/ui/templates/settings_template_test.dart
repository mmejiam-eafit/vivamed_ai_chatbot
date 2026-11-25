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

    // ── Expanded and up: one column beside the menu rail (DL D-025) ─────────

    group('expanded and up (>= threePaneMinWidth)', () {
      Future<void> pumpExpanded(WidgetTester tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: SettingsTemplate(appBar: AppBar(), sections: threeSections),
          ),
        );
      }

      testWidgets('shows every title once and every section\'s content',
          (tester) async {
        await pumpExpanded(tester);
        // Once each: the section card's own heading, with no index beside it.
        expect(find.text('Account'), findsOneWidget);
        expect(find.text('Display'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
        expect(find.text('account-content'), findsOneWidget);
        expect(find.text('display-content'), findsOneWidget);
        expect(find.text('about-content'), findsOneWidget);
      });

      testWidgets('content is capped at 720', (tester) async {
        await pumpExpanded(tester);
        expect(
          find.byWidgetPredicate(
            (w) => w is ConstrainedBox && w.constraints.maxWidth == 720,
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets(
        'expandedMinWidth (below threePaneMinWidth): still the medium column, '
        'capped at 640, not the wide one -- the exact gap this boundary '
        'alignment closes', (tester) async {
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
      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 640,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 720,
        ),
        findsNothing,
      );
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
