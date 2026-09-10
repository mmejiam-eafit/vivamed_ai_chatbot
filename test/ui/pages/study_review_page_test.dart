import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

void main() {
  group('StudyReviewPage', () {
    testWidgets('renders StudyReviewTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(StudyReviewTemplate), findsOneWidget);
    });

    testWidgets('renders Study Review in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.text('Study Review'), findsOneWidget);
    });

    testWidgets('renders FindingsPanel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(FindingsPanel), findsOneWidget);
    });

    testWidgets('renders ChatPanel slot', (tester) async {
      // Wide, not the default size: below threePaneMinWidth, chat lives
      // inside the (unselected-by-default) second tab and isn't laid out.
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: below twoPaneMinWidth (narrow) ────────────────

    testWidgets('narrow below twoPaneMinWidth: TabBar is visible',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.twoPaneMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('narrow below twoPaneMinWidth: drawer assigned to Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.twoPaneMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    // ── Responsive breakpoint: twoPaneMinWidth to threePaneMinWidth ──────────
    // (viewer + tabs — still has a TabBar; nav and chat aren't yet separate
    // zones, so the drawer stays an overlay too)

    testWidgets('viewer + tabs at twoPaneMinWidth: TabBar still visible',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.twoPaneMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(TabBar), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    // ── Responsive breakpoint: threePaneMinWidth (three-zone) ────────────────

    testWidgets('three-zone at threePaneMinWidth: no TabBar, Row layout',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(Row), findsWidgets);
    });
  });
}
