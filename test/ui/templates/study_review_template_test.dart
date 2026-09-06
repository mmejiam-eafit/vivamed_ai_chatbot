import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

void main() {
  group('StudyReviewTemplate', () {
    testWidgets('renders appBar slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(title: const Text('Study')),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
          ),
        ),
      );
      expect(find.text('Study'), findsOneWidget);
    });

    testWidgets('renders imageViewer slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const Text('img'),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
          ),
        ),
      );
      expect(find.text('img'), findsOneWidget);
    });

    testWidgets('renders findingsPanel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const Text('findings'),
            chatPanel: const SizedBox(),
          ),
        ),
      );
      expect(find.text('findings'), findsOneWidget);
    });

    testWidgets('renders chatPanel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const Text('chat'),
          ),
        ),
      );
      expect(find.text('chat'), findsOneWidget);
    });

    testWidgets('renders statusBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
            statusBar: const Text('status'),
          ),
        ),
      );
      expect(find.text('status'), findsOneWidget);
    });

    testWidgets('statusBar is absent when null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
          ),
        ),
      );
      expect(find.text('status'), findsNothing);
    });

    testWidgets('has Scaffold with surfacePage background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
          ),
        ),
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.surfacePage,
      );
    });

    group('narrow layout (< 768px)', () {
      setUp(() {});

      testWidgets('shows TabBar with Findings and Chat tabs', (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
            ),
          ),
        );
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.text('Findings'), findsOneWidget);
        expect(find.text('Chat'), findsOneWidget);
      });

      testWidgets('drawer is passed to Scaffold.drawer on narrow',
          (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
              drawer: const Text('drawer-content'),
            ),
          ),
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.drawer, isNotNull);
      });

      testWidgets('uses narrow layout below template split width',
          (tester) async {
        const width = AppLayout.templateSplitWidth - 1;
        tester.view.physicalSize = const Size(width * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
            ),
          ),
        );

        expect(find.byType(TabBar), findsOneWidget);
      });
    });

    group('wide layout (>= 768px)', () {
      testWidgets('shows Row layout, no TabBar', (tester) async {
        tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
            ),
          ),
        );
        expect(find.byType(TabBar), findsNothing);
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('drawer is rendered inline (Scaffold.drawer is null) on wide',
          (tester) async {
        tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
              drawer: const Text('drawer-content'),
            ),
          ),
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.drawer, isNull);
        expect(find.text('drawer-content'), findsOneWidget);
      });

      testWidgets('uses wide layout at template split width', (tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
            ),
          ),
        );

        expect(find.byType(TabBar), findsNothing);
        expect(find.byType(Row), findsWidgets);
      });

      testWidgets(
          'wide layout applies panel spacing and drawer width contracts',
          (tester) async {
        tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
              drawer: const SizedBox(),
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find
              .descendant(
                  of: find.byType(StudyReviewTemplate),
                  matching: find.byType(Padding))
              .first,
        );
        final insets = padding.padding as EdgeInsets;
        expect(insets.left, AppSpacing.lg);
        expect(insets.top, AppSpacing.lg);

        expect(
          find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.height == AppSpacing.lg,
          ),
          findsWidgets,
        );

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is SizedBox &&
                widget.width == NavigationTokens.sideNavWidth,
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets('narrow layout applies aspect ratio and spacing contracts',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: StudyReviewTemplate(
            appBar: AppBar(),
            imageViewer: const SizedBox(),
            findingsPanel: const SizedBox(),
            chatPanel: const SizedBox(),
          ),
        ),
      );

      final aspect = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspect.aspectRatio, 4 / 3);

      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == AppSpacing.sm,
        ),
        findsOneWidget,
      );
    });
  });
}
