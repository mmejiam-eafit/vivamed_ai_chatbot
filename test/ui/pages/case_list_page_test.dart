import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/case_worklist_table.dart';
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

    // ── Responsive breakpoint: mediumMinWidth - 1 (narrow) ───────────────────

    testWidgets('narrow below mediumMinWidth: ListView visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.mediumMinWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    // ── Responsive breakpoint: mediumMinWidth (wide — at split) ──────────────

    testWidgets('wide at mediumMinWidth: two-column Wrap visible', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Responsive breakpoint: mediumMinWidth + 1 (wide — above split) ───────

    testWidgets('wide above mediumMinWidth: two-column Wrap visible', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.mediumMinWidth + 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    // ── Responsive breakpoint: expandedMinWidth (worklist table) ────────────

    testWidgets('expanded: renders CaseWorklistTable slot, no grid or list',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const CaseListPage()),
      );

      expect(find.byType(CaseWorklistTable), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });
  });
}
