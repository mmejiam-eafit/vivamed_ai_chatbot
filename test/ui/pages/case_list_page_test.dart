import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

void main() {
  group('CaseListPage', () {
    testWidgets('renders CaseListTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(CaseListTemplate), findsOneWidget);
    });

    testWidgets('renders Cases in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.text('Cases'), findsOneWidget);
    });

    testWidgets('renders placeholder case cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(StudyInfoCard), findsNWidgets(2));
    });

    testWidgets('renders case titles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.text('Chest X-Ray'), findsOneWidget);
      expect(find.text('Abdominal CT'), findsOneWidget);
    });

    // ── Responsive breakpoint: 767 (narrow) ──────────────────────────────────

    testWidgets('narrow at 767: ListView visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    // ── Responsive breakpoint: 768 (wide — at split) ─────────────────────────

    testWidgets('wide at 768: GridView visible', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Responsive breakpoint: 769 (wide — above split) ──────────────────────

    testWidgets('wide at 769: GridView visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth + 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });
  });
}
