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
            emptyState: const Text('no cases'),
          ),
        ),
      );
      expect(find.text('no cases'), findsNothing);
    });

    testWidgets('narrow layout uses ListView', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
          ),
        ),
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('wide layout uses GridView', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
          ),
        ),
      );
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('uses ListView below template split width', (tester) async {
      const width = AppLayout.templateSplitWidth - 1;
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
          ),
        ),
      );
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
    });

    testWidgets('uses GridView at template split width', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
          ),
        ),
      );
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('applies header padding contract', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [],
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

    testWidgets('applies list padding on narrow layout', (tester) async {
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
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      final insets = listView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);
    });

    testWidgets('applies grid delegate contract on wide layout',
        (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(
            appBar: AppBar(),
            caseSlots: const [Text('a'), Text('b')],
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final insets = gridView.padding! as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
      expect(delegate.crossAxisSpacing, AppSpacing.lg);
      expect(delegate.mainAxisSpacing, AppSpacing.lg);
      expect(delegate.childAspectRatio, 1.4);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: CaseListTemplate(appBar: AppBar(), caseSlots: const []),
        ),
      );
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.surfacePage);
    });
  });
}
