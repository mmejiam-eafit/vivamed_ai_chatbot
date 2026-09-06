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
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: 767 (narrow) ──────────────────────────────────

    testWidgets('narrow at 767: TabBar is visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(TabBar), findsOneWidget);
    });

    testWidgets('narrow at 767: drawer assigned to Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    // ── Responsive breakpoint: 768 (wide — at split) ─────────────────────────

    testWidgets('wide at 768: no TabBar', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const StudyReviewPage()),
      );

      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(Row), findsWidgets);
    });

    // ── Responsive breakpoint: 769 (wide — above split) ──────────────────────

    testWidgets('wide at 769: Row layout, no TabBar', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth + 1) * 3, 844 * 3);
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
