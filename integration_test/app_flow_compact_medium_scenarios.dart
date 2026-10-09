import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
import 'package:radiologist_helper/ui/organisms/collapsed_nav_rail.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/home_hub_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

import 'support/app_flow_support.dart';

/// The same three journeys as `app_flow_scenarios.dart`, below the wide tier:
/// compact (phone) and medium (tablet). Not a parameterized copy of the wide
/// flows -- below `threePaneMinWidth` the navigation model is different (app
/// bars, a bottom nav bar on some pages, slide-over drawers, system back), so
/// the steps differ. Compact and medium, though, take the same steps and
/// differ only in the layout they land on, so each journey runs once per tier
/// from the data in [_tiers].
///
/// Where it runs decides the tier. On a phone or tablet (a real device or an
/// emulator, `flutter test integration_test -d <android-device>`) the screen
/// is the tier: nothing is pinned, and the one tier the device's logical width
/// falls into is the one that runs, so a phone runs compact and a small
/// tablet in landscape runs medium -- real touch, back gesture, insets and
/// density rather than a resized desktop window. A device that is neither (a
/// wide tablet) fails loudly instead of running something it can't test. On
/// desktop, run directly by path, both tiers run at the pinned sizes below;
/// `app_test.dart` leaves this file out of the desktop run.
class _Tier {
  const _Tier({
    required this.name,
    required this.size,
    required this.casesInTwoColumns,
    required this.hasConversationRail,
  });

  final String name;
  final Size size;

  /// Case List: a single column of cards at compact, two columns at medium.
  final bool casesInTwoColumns;

  /// Chat: conversations behind an app-bar hamburger only at compact; medium
  /// adds the 64px collapsed rail, with its own button for the same drawer.
  final bool hasConversationRail;
}

const _tiers = [
  // A common phone: below compactMaxWidth (599).
  _Tier(
    name: 'compact',
    size: Size(390, 844),
    casesInTwoColumns: false,
    hasConversationRail: false,
  ),
  // A tablet. Pinned at 800x900 (below twoPaneMinWidth, so Study Review keeps
  // its tabs under the viewer); a real small tablet in landscape is typically
  // wider (960 logical px puts the viewer beside the tabs), and the journeys
  // take the same steps either way.
  _Tier(
    name: 'medium',
    size: Size(800, 900),
    casesInTwoColumns: true,
    hasConversationRail: true,
  ),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (!isMobileDevice) {
    for (final tier in _tiers) {
      _journeys(tier);
    }
    return;
  }

  final width = deviceLogicalSize.width;
  final tier = _tierOf(width);
  if (tier == null) {
    testWidgets('this device is a compact or medium screen', (tester) async {
      fail(
        'The screen is $width logical px wide, which is the wide tier '
        '(>= ${AppLayout.threePaneMinWidth.toInt()}). These journeys cover '
        'phones and small tablets; run them on a narrower device or AVD.',
      );
    });
    return;
  }
  _journeys(tier);
}

/// The tier a screen of [width] logical px lands in, using the same boundary
/// the templates use for their chrome (app bars and bottom nav bars go away at
/// `threePaneMinWidth`), or null if it is wider.
_Tier? _tierOf(double width) {
  if (width < AppLayout.mediumMinWidth) return _tiers.first;
  if (width < AppLayout.threePaneMinWidth) return _tiers.last;
  return null;
}

/// Taps [destination] on the bottom nav bar -- the primary navigation at
/// these tiers, on the pages that have one (Case List, Settings, Chat).
Future<void> goViaNavBar(WidgetTester tester, String destination) async {
  // Scoped to the bar: the Hub's and Settings' own app-bar titles also read
  // 'Home' / 'Settings', and the Chat drawer has its own 'Settings' row.
  await tester.tap(
    find.descendant(
      of: find.byType(AppNavBar),
      matching: find.text(destination),
    ),
  );
  await tester.pumpAndSettle();
}

/// What a phone or tablet user has where a page shows no back control:
/// Android's back button / gesture, delivered the way the platform delivers it.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void _journeys(_Tier tier) {
  testWidgets('${tier.name}: hub -> studies -> settings -> dark mode -> home '
      'via the bottom nav bar', (tester) async {
    pinWindow(tester, tier.size);
    await signInToHub(tester);

    await tester.tap(find.text('View studies'));
    await tester.pumpAndSettle();
    expect(find.byType(CaseListPage), findsOneWidget);
    // Cards and a bottom nav bar here, not the wide tier's table and Menu.
    expect(find.byType(StudyInfoCard), findsWidgets);
    expect(find.byType(CaseWorklistTable), findsNothing);
    expect(find.byType(AppNavBar), findsOneWidget);
    // One column of cards, or two: the first two cards share a row only in
    // the two-column layout.
    final firstCard = tester.getTopLeft(find.byType(StudyInfoCard).at(0));
    final secondCard = tester.getTopLeft(find.byType(StudyInfoCard).at(1));
    expect(firstCard.dy == secondCard.dy, tier.casesInTwoColumns);

    await goViaNavBar(tester, 'Settings');
    expect(find.byType(SettingsPage), findsOneWidget);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    var app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    // Home pops to the root, which is the Hub.
    await goViaNavBar(tester, 'Home');
    expect(find.byType(HomeHubPage), findsOneWidget);
    expect(find.text('Upload a study'), findsOneWidget);

    // The Hub has no bottom nav; its app bar's gear is how Settings is
    // reached from here. It pushes, so the chrome stays an app bar + nav bar.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets(
    '${tier.name}: case card -> study review -> heatmap -> similar cases -> '
    'system back to hub, and chat -> case reference -> study review',
    (tester) async {
      pinWindow(tester, tier.size);
      await signInToHub(tester);

      await tester.tap(find.text('View studies'));
      await tester.pumpAndSettle();

      // Cards show titles, not patients. case-1 is "Chest X-Ray".
      await tester.tap(find.text('Chest X-Ray'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);
      // Findings and Chat share the tab strip below the image at this width. The
      // app bar has the conversation drawer's hamburger rather than a back
      // button -- Flutter's AppBar gives the drawer priority.
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(DrawerButton), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);

      // Findings is the first tab, so it's already showing.
      await tester.tap(find.text('Right lower lobe consolidation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Heatmap'));
      await tester.pumpAndSettle();
      expect(find.byType(HeatmapViewerPage), findsOneWidget);
      expect(find.text('Heatmap'), findsOneWidget);

      // Heatmap's app bar has a real back button -- the point of this step is
      // that it can actually be tapped.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      await tester.tap(find.text('View Similar Studies'));
      await tester.pumpAndSettle();
      expect(find.byType(SimilarCasesPage), findsOneWidget);
      expect(find.text('3 similar cases found'), findsOneWidget);
      // No nav bar and no drawer on this page: just an app bar with back.
      expect(find.byType(AppNavBar), findsNothing);
      expect(find.byType(BackButton), findsOneWidget);

      // Similar Cases excludes case-1: case-2 is "Abdominal CT".
      await tester.tap(find.text('Abdominal CT'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);

      // Study Review shows no back control here, so a phone user unwinds with
      // the system back gesture: one route per press, back to the Hub.
      await systemBack(tester);
      expect(find.byType(SimilarCasesPage), findsOneWidget);
      await systemBack(tester);
      expect(find.byType(StudyReviewPage), findsOneWidget);
      await systemBack(tester);
      expect(find.byType(CaseListPage), findsOneWidget);
      await systemBack(tester);
      expect(find.byType(HomeHubPage), findsOneWidget);

      // Chat -> tap a case reference chip -> Study Review, same conversation.
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);

      await scrollIntoView(tester, find.text('Abdominal CT'));
      await tester.tap(find.text('Abdominal CT'));
      await tester.pumpAndSettle();
      expect(find.byType(StudyReviewPage), findsOneWidget);
    },
  );

  testWidgets('${tier.name}: chat -> switch conversation in the drawer -> its '
      'Settings row pushes, back returns to the same conversation', (
    tester,
  ) async {
    pinWindow(tester, tier.size);
    await signInToHub(tester);

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Conversations live in a slide-over here (inline at the wide tier). The
    // app bar's hamburger opens it at both tiers; medium also has the
    // collapsed rail, whose own button opens the same drawer -- use that one
    // first, since it is the control only this tier has.
    expect(
      find.byType(CollapsedNavRail),
      tier.hasConversationRail ? findsOneWidget : findsNothing,
    );
    await tester.tap(
      tier.hasConversationRail
          ? find.byTooltip('Conversations')
          : find.byType(DrawerButton),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ConversationDrawer), findsOneWidget);

    // conv-2's title, from the mock conversation list. Selecting doesn't
    // close the drawer (ConversationDrawer only calls onSelect), so dismiss
    // it the way a user would: tap the scrim to its right.
    await tester.tap(find.text('Abdominal CT — Patient 2'));
    await tester.pumpAndSettle();
    // To the right of the 280px drawer, in the screen's own coordinates (not
    // [_Tier.size], which is only what desktop pins).
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(screen.width - 10, 400));
    await tester.pumpAndSettle();
    expect(find.byType(ConversationDrawer), findsNothing);

    // Its own messages (from conversation_mocks.dart) are now showing.
    await scrollIntoView(tester, find.text('Any acute abdominal findings?'));
    expect(find.text('Any acute abdominal findings?'), findsOneWidget);

    // The drawer's own Settings row *pushes* (unlike the wide tier's Menu,
    // whose destinations replace), so Chat survives underneath.
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(ConversationDrawer),
        matching: find.text('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);

    // A pushed page gets an automatic back button.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ChatPage), findsOneWidget);
    await scrollIntoView(tester, find.text('Any acute abdominal findings?'));
    expect(find.text('Any acute abdominal findings?'), findsOneWidget);
  });
}
