import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
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
  });
}
