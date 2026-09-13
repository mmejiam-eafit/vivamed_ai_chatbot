import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';

/// Drives the real, compiled app end-to-end (real platform channels, real
/// on-disk shared_preferences) -- not the widget-test harness. Run with:
/// `flutter test tests/integration/app_flow_test.dart -d <device>`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full flow: login -> onboarding -> hub -> nav bar -> dark mode',
      (tester) async {
    final themeController = await ThemeController.load();
    await tester.pumpWidget(
      ProviderScope(child: App(themeController: themeController)),
    );
    await tester.pumpAndSettle();

    // Not find.text('Sign In') -- LoginPage has both a heading and the
    // button reading exactly that (confirmed by login_page_test.dart's own
    // findsWidgets assertion for it). LoginPage has exactly one AppButton.
    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    // Real on-disk shared_preferences persists has_completed_onboarding
    // across runs on this machine -- so this run may land on Onboarding
    // (first run) or go straight to Home Hub (already onboarded). Handle
    // both rather than assuming one.
    if (find.text('Home').evaluate().isEmpty) {
      // Onboarding: walk to the last slide, then Get Started.
      while (tester.widget<AppButton>(find.byType(AppButton)).label !=
          'Get Started') {
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
    }

    expect(find.text('Home'), findsOneWidget); // Home Hub app bar

    await tester.tap(find.text('View studies'));
    await tester.pumpAndSettle();
    expect(find.text('Cases'), findsOneWidget);
    expect(find.text('Studies'), findsWidgets); // nav bar label

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // A real desktop window is wide enough to hit SettingsTemplate's
    // two-column tier, which shows one section at a time (default: Account)
    // -- select Appearance first. No-op in the single-column layout, where
    // every section (including Appearance) is already visible.
    if (find.text('Appearance').evaluate().isNotEmpty) {
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Upload a study'), findsOneWidget); // back at the Hub
  });

  testWidgets(
      'case list -> study review -> heatmap -> similar cases -> back to hub, '
      'and chat -> case reference -> study review', (tester) async {
    final themeController = await ThemeController.load();
    await tester.pumpWidget(
      ProviderScope(child: App(themeController: themeController)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    if (find.text('Home').evaluate().isEmpty) {
      while (tester.widget<AppButton>(find.byType(AppButton)).label !=
          'Get Started') {
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
    }

    // CaseListTemplate/StudyReviewTemplate both branch on real window width
    // (cards vs. worklist table; three-zone vs. tabs) -- tap whichever of a
    // title/tab-label or its narrower-tier fallback is actually on screen,
    // rather than assuming one tier.
    Future<void> tapFirstMatch(List<String> candidates) async {
      for (final text in candidates) {
        final finder = find.text(text);
        if (finder.evaluate().isNotEmpty) {
          await tester.tap(finder.first);
          await tester.pumpAndSettle();
          return;
        }
      }
      fail('None of $candidates were found on screen');
    }

    await tester.tap(find.text('View studies'));
    await tester.pumpAndSettle();

    // case-1 ("Chest X-Ray" / patient "Anonymous 1").
    await tapFirstMatch(['Chest X-Ray', 'Anonymous 1']);
    expect(find.text('Study Review'), findsOneWidget);

    // Narrow tiers put findings behind a tab; wide tiers show it inline.
    if (find.text('Findings').evaluate().isNotEmpty) {
      await tester.tap(find.text('Findings').first);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Right lower lobe consolidation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Heatmap'));
    await tester.pumpAndSettle();
    expect(find.text('Heatmap'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    if (find.text('Findings').evaluate().isNotEmpty) {
      await tester.tap(find.text('Findings').first);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('View Similar Studies'));
    await tester.pumpAndSettle();
    expect(find.text('Similar Cases'), findsOneWidget);

    // Similar Cases excludes case-1: case-2 is "Abdominal CT" / "Anonymous 2".
    await tapFirstMatch(['Abdominal CT', 'Anonymous 2']);
    expect(find.text('Study Review'), findsOneWidget);

    // Unwind 4 levels: Study Review(2nd) -> Similar Cases -> Study Review
    // (1st) -> Case List -> Home Hub.
    for (var i = 0; i < 4; i++) {
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(find.text('Upload a study'), findsOneWidget);

    // Chat -> tap a case reference chip -> Study Review, same conversation.
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Abdominal CT'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Abdominal CT'));
    await tester.pumpAndSettle();
    expect(find.text('Study Review'), findsOneWidget);
  });

  testWidgets('chat -> switch conversation in the drawer -> drawer Settings',
      (tester) async {
    final themeController = await ThemeController.load();
    await tester.pumpWidget(
      ProviderScope(child: App(themeController: themeController)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();
    if (find.text('Home').evaluate().isEmpty) {
      while (tester.widget<AppButton>(find.byType(AppButton)).label !=
          'Get Started') {
        await tester.tap(find.byType(AppButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // conv-2's title, from the mock conversation list -- switch to it.
    await tester.tap(find.text('Abdominal CT — Patient 2'));
    await tester.pumpAndSettle();

    // Its own messages (from conversation_mocks.dart) should now be showing.
    await tester.scrollUntilVisible(
      find.text('Any acute abdominal findings?'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Any acute abdominal findings?'), findsOneWidget);

    // The drawer's own Settings item -- not the bottom nav bar's.
    await tester.tap(find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Settings'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);

    // Pushed, not replaced -- confirms it didn't discard the Chat screen.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Any acute abdominal findings?'), findsOneWidget);
  });
}
