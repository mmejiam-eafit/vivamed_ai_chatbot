import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

import 'support/app_flow_support.dart';

/// Drives the real, compiled app end-to-end (real platform channels, real
/// on-disk shared_preferences, default mock data) -- not the widget-test
/// harness. Run with: `flutter test integration_test -d <device>` (all
/// scenarios, one app launch -- see `app_test.dart`), or this file alone by
/// explicit path.
///
/// Wide tier (1280x720), plus the case-list -> study-review journey again at
/// ultrawide (1920x1080): that is the one journey that reaches every
/// ultrawide-sensitive page, and the steps are identical at both, so it runs
/// once per size (nothing else exercised layouts above 1600px). Compact and
/// medium widths are `app_flow_compact_medium_scenarios.dart`, which runs on
/// real Android devices rather than a resized desktop window.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 1280x720 is the Linux runner's own default window
  // (linux/runner/my_application.cc), i.e. the window these flows were written
  // for -- pinned so a different host window can't silently change the tier.
  // At this tier (>= threePaneMinWidth) Home Hub, Case List, Similar Cases and
  // Study Review have no app bar (so no title text and no back button), the
  // bottom nav bar is gone, and navigation goes through the "Menu" row, which
  // opens PrimaryNavDrawer.
  const wideSize = Size(1280, 720);

  // Above ultrawideMinWidth (1600). Navigation chrome is the same as at wide
  // (app bars and nav bars switch at threePaneMinWidth, not here); what
  // changes is a few page layouts, Study Review's side-by-side one being the
  // distinctive one.
  const ultrawideSize = Size(1920, 1080);

  /// Open PrimaryNavDrawer from the persistent "Menu" row and pick
  /// [destination] (the recipe home_hub_page_test.dart/case_list_page_test.dart
  /// already use).
  Future<void> goViaMenu(WidgetTester tester, String destination) async {
    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text(destination),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('full flow: login -> onboarding -> hub -> studies -> settings -> '
      'dark mode -> home', (tester) async {
    pinWindow(tester, wideSize);
    await signInToHub(tester);

    await tester.tap(find.text('View studies'));
    await tester.pumpAndSettle();
    expect(find.byType(CaseListPage), findsOneWidget);
    expect(find.byType(CaseWorklistTable), findsOneWidget);

    await goViaMenu(tester, 'Settings');
    expect(find.byType(SettingsPage), findsOneWidget);

    // Every Settings section is visible at once (50c312d) -- no need to pick
    // Appearance from the index rail first.
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await goViaMenu(tester, 'Home');
    expect(find.text('Upload a study'), findsOneWidget); // back at the Hub
  });

  for (final (label, size) in [
    ('wide', wideSize),
    ('ultrawide', ultrawideSize),
  ]) {
    testWidgets('$label: case list -> study review -> heatmap -> similar cases -> back '
        'to hub, and chat -> case reference -> study review', (tester) async {
      pinWindow(tester, size);
      await signInToHub(tester);

      await tester.tap(find.text('View studies'));
      await tester.pumpAndSettle();

      // The worklist table shows patients, not titles. case-1 is
      // "Chest X-Ray" / patient "Anonymous 1".
      await tester.tap(find.text('Anonymous 1'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      // The one layout that differs by width: above ultrawideMinWidth the viewer
      // and findings sit side by side, below it findings stack under the viewer.
      // Checked with the real AppImage/FindingsPanel (the template tests use
      // Text stand-ins). Deliberately only the arrangement -- beside vs. below,
      // never a shared top edge: the image is centred inside the canvas that
      // fills its slot (BoxFit.contain), so the image's own top differs from
      // the findings' even though the slots align.
      final viewer = tester.getRect(find.byType(AppImage));
      final findings = tester.getRect(find.byType(FindingsPanel));
      if (size.width >= AppLayout.ultrawideMinWidth) {
        expect(
          findings.left,
          greaterThanOrEqualTo(viewer.right),
          reason: 'findings should sit to the right of the viewer',
        );
        expect(
          findings.top,
          lessThan(viewer.bottom),
          reason: 'side by side means the two overlap vertically',
        );
        expect(viewer.top, lessThan(findings.bottom));
      } else {
        expect(
          findings.top,
          greaterThanOrEqualTo(viewer.bottom),
          reason: 'findings should sit under the viewer',
        );
        expect(
          findings.left,
          lessThan(viewer.right),
          reason: 'stacked means the two overlap horizontally',
        );
        expect(viewer.left, lessThan(findings.right));
      }

      // Three-zone layout: findings are inline, no tab to pick first.
      await tester.tap(find.text('Right lower lobe consolidation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Heatmap'));
      await tester.pumpAndSettle();
      expect(find.byType(HeatmapViewerPage), findsOneWidget);
      expect(find.text('Heatmap'), findsOneWidget);

      // Heatmap keeps its app bar (and has no drawer), so this is a real back
      // button.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      await tester.tap(find.text('View Similar Studies'));
      await tester.pumpAndSettle();
      expect(find.byType(SimilarCasesPage), findsOneWidget);
      expect(find.text('3 similar cases found'), findsOneWidget);

      // Similar Cases excludes case-1: case-2 is "Abdominal CT" / "Anonymous 2".
      await tester.tap(find.text('Anonymous 2'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      // No app bars left to pop with at this tier -- the Menu's Home entry is
      // the way back, and it pops the whole stack to the root.
      await goViaMenu(tester, 'Home');
      expect(find.text('Upload a study'), findsOneWidget);

      // Chat -> tap a case reference chip -> Study Review, same conversation.
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);

      await scrollIntoView(tester, find.text('Abdominal CT'));
      await tester.tap(find.text('Abdominal CT'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);
    });
  }

  testWidgets('chat -> switch conversation -> Settings via the menu', (
    tester,
  ) async {
    pinWindow(tester, wideSize);
    await signInToHub(tester);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // conv-2's title, from the mock conversation list -- inline at this tier.
    await tester.tap(find.text('Abdominal CT — Patient 2'));
    await tester.pumpAndSettle();

    // Its own messages (from conversation_mocks.dart) should now be showing.
    await scrollIntoView(tester, find.text('Any acute abdominal findings?'));
    expect(find.text('Any acute abdominal findings?'), findsOneWidget);

    // The drawer's bottom row is "Menu" here, and destinations *replace*
    // (unlike compact/medium, where the drawer's own Settings row pushes and
    // Chat survives underneath).
    await goViaMenu(tester, 'Settings');
    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.byType(ChatPage), findsNothing);
  });
}
