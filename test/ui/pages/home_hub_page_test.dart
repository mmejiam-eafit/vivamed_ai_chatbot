import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/home_hub_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/upload_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Async: SettingsPage (one of the four destinations) reads
  // ThemeControllerScope.of(context), so every test needs a real loaded
  // controller as an ancestor, not just the provider-consuming pages' mocks.
  Future<Widget> wrap() async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    // ThemeControllerScope must wrap MaterialApp itself, not just `home` --
    // routes pushed later via Navigator.push land in sibling Overlay
    // entries, outside anything placed only inside `home`.
    return ProviderScope(
      child: ThemeControllerScope(
        controller: controller,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const HomeHubPage(),
        ),
      ),
    );
  }

  group('HomeHubPage', () {
    testWidgets('tapping Upload a study opens UploadPage', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upload a study'));
      await tester.pumpAndSettle();

      expect(find.byType(UploadPage), findsOneWidget);
    });

    testWidgets('tapping View studies opens CaseListPage', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('View studies'));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
    });

    testWidgets('tapping Chat opens ChatPage', (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
    });

    testWidgets('tapping the settings icon opens SettingsPage',
        (tester) async {
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    // ── Primary nav drawer (expanded/ultrawide) ──────────────────────────

    void setWideSize(WidgetTester tester) {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('drawer: opens with Home selected -- Home Hub is the root',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      // No app bar/hamburger at this tier anymore -- MenuRail's own "Menu"
      // trigger opens it instead.
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      final drawer =
          tester.widget<PrimaryNavDrawer>(find.byType(PrimaryNavDrawer));
      expect(drawer.selectedIndex, 0);
    });

    testWidgets('drawer: tapping Chat replaces with ChatPage', (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Chat'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ChatPage), findsOneWidget);
      expect(find.byType(HomeHubPage), findsNothing);
    });

    testWidgets('drawer: tapping Studies replaces with CaseListPage',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Studies'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListPage), findsOneWidget);
      expect(find.byType(HomeHubPage), findsNothing);
    });

    testWidgets('drawer: tapping Settings replaces with SettingsPage',
        (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(await wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Settings'),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(HomeHubPage), findsNothing);
    });
  });
}
