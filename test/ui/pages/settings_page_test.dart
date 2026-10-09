import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
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

  // For nav-bar tests that push/replace routes: ThemeControllerScope must
  // wrap MaterialApp itself, not just `home` -- routes added later land in
  // sibling Overlay entries that a scope placed only inside `home` doesn't
  // cover (see home_hub_page_test.dart, where this was first hit).
  Future<Widget> wrapForNav(Widget root) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    return ProviderScope(
      child: ThemeControllerScope(
        controller: controller,
        child: MaterialApp(theme: buildAppTheme(), home: root),
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
      // Not a bare find.text('Settings') -- the nav bar's own "Settings"
      // destination label renders on this page too.
      expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.text('Settings')),
        findsOneWidget,
      );
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

    // ── Nav bar (own index 3) ────────────────────────────────────────────

    testWidgets('tapping Home in the nav bar pops back to the root',
        (tester) async {
      await tester.pumpWidget(await wrapForNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                child: const Text('go to settings'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('tapping Chat in the nav bar replaces with ChatPage',
        (tester) async {
      await tester.pumpWidget(await wrapForNav(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('tapping Studies in the nav bar replaces with CaseListPage',
        (tester) async {
      await tester.pumpWidget(await wrapForNav(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Studies'));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────

    void setWideSize(WidgetTester tester) {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('drawer: tapping Home pops back to the root', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrapForNav(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
                child: const Text('go to settings'),
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('go to settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);

      // No app bar/hamburger at this tier anymore -- MenuRail's own "Menu"
      // trigger opens it instead.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Home'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsNothing);
    });

    testWidgets('drawer: tapping Studies replaces with CaseListPage',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrapForNav(const SettingsPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Studies'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(SettingsPage), findsNothing);
    });
  });
}
