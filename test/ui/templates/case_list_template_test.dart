import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

void main() {
  group('CaseListTemplate', () {
    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(title: const Text('Cases')),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('Cases'), findsOneWidget);
    });

    testWidgets('renders all caseSlots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('case-1'), Text('case-2'), Text('case-3')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('case-1'), findsOneWidget);
      expect(find.text('case-2'), findsOneWidget);
      expect(find.text('case-3'), findsOneWidget);
    });

    testWidgets('renders header slot when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            header: const Text('section header'),
          ),
        ),
      );
      expect(find.text('section header'), findsOneWidget);
    });

    testWidgets('header is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('section header'), findsNothing);
    });

    testWidgets('renders statusBar slot when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            statusBar: const Text('status'),
          ),
        ),
      );
      expect(find.text('status'), findsOneWidget);
    });

    testWidgets('renders emptyState when caseSlots is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsOneWidget);
    });

    testWidgets('emptyState is absent when caseSlots is non-empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a')],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsNothing);
    });

    // ── Compact: ListView (< mediumMinWidth) ──────────────────────────────

    testWidgets('uses ListView below mediumMinWidth', (tester) async {
      const width = AppLayout.mediumMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.text('table'), findsNothing);
    });

    testWidgets('applies list padding on compact', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final insets = listView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);
    });

    // ── Medium: GridView (mediumMinWidth to expandedMinWidth) ─────────────

    testWidgets('uses a two-column Wrap at mediumMinWidth, not GridView',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.text('table'), findsNothing);
    });

    testWidgets('applies wrap spacing and padding contract at medium',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final scrollView =
          tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
      final insets = scrollView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, AppSpacing.lg);
      expect(wrap.runSpacing, AppSpacing.lg);

      // Both slots share the same, equal column width -- confirms a real
      // two-column split, not one slot claiming more than its share.
      final widthA = tester.getSize(find.ancestor(
        of: find.text('a'),
        matching: find.byType(SizedBox),
      ).first).width;
      final widthB = tester.getSize(find.ancestor(
        of: find.text('b'),
        matching: find.byType(SizedBox),
      ).first).width;
      expect(widthA, widthB);
    });

    // ── Gap 20: cells reflow instead of clipping ──────────────────────────

    testWidgets('a taller slot grows its row rather than being clipped',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Taller than the old fixed childAspectRatio: 1.4 cell would allow at
      // this width -- that delegate clipped or scrolled content like this
      // inside its own cell instead of letting the row grow.
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [
              SizedBox(height: 500, child: Text('tall card')),
              Text('short card'),
            ],
            worklistTable: const Text('table'),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final tallSlotHeight = tester.getSize(find.ancestor(
        of: find.text('tall card'),
        matching: find.byType(SizedBox),
      ).first).height;
      expect(tallSlotHeight, greaterThanOrEqualTo(500));
    });

    testWidgets('survives 200% text scale without overflowing', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: MaterialApp(
            theme: buildAppTheme(),
            home: CaseListTemplate(
              appBar: AppBar(),
              caseSlots: const [
                Text('Chest X-Ray with a fairly long descriptive title'),
                Text('CT'),
              ],
              worklistTable: const Text('table'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    // ── Expanded/ultrawide: worklistTable slot ────────────────────────────

    testWidgets('uses the worklistTable slot at expandedMinWidth',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );
      expect(find.text('table'), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('caps the worklistTable at worklistMaxWidth at ultrawide',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.ultrawideMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
            worklistTable: const Text('table'),
          ),
        ),
      );

      final box = tester.widget<ConstrainedBox>(find.ancestor(
        of: find.text('table'),
        matching: find.byType(ConstrainedBox),
      ));
      expect(box.constraints.maxWidth, AppLayout.worklistMaxWidth);
    });

    testWidgets('emptyState still wins over worklistTable when empty',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.expandedMinWidth * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsOneWidget);
      expect(find.text('table'), findsNothing);
    });

    // ── Other ──────────────────────────────────────────────────────────────

    testWidgets('applies header padding contract', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            header: const Text('header'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.ancestor(of: find.text('header'), matching: find.byType(Padding)),
      );
      final insets = padding.padding as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);
      expect(insets.right, AppSpacing.lg);
      expect(insets.bottom, 0);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.light.surfacePage);
    });

    testWidgets('resolves against the dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(Brightness.dark),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });

    testWidgets('navBar is passed to Scaffold.bottomNavigationBar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(find.text('nav-bar-slot'), findsOneWidget);
    });

    testWidgets('navBar is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
            worklistTable: const Text('table'),
          ),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });
  });
}
