import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
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
      // Wide, not the default size: below threePaneMinWidth, chat lives
      // inside the (unselected-by-default) second tab and isn't laid out.
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 800 * 3);
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
        AppColorsData.light.surfacePage,
      );
    });

    group('narrow layout (< twoPaneMinWidth)', () {
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

      testWidgets('uses narrow layout up to twoPaneMinWidth - 1',
          (tester) async {
        const width = AppLayout.twoPaneMinWidth - 1;
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
        expect(find.byType(AspectRatio), findsOneWidget);
      });
    });

    group('viewer + tabs layout (twoPaneMinWidth to threePaneMinWidth - 1)',
        () {
      testWidgets('shows the tabs beside the viewer, not stacked under it',
          (tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.twoPaneMinWidth * 3, 800 * 3);
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
        expect(find.byType(AspectRatio), findsNothing);
      });

      testWidgets('drawer stays an overlay just below threePaneMinWidth',
          (tester) async {
        const width = AppLayout.threePaneMinWidth - 1;
        tester.view.physicalSize = const Size(width * 3, 800 * 3);
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
    });

    group('three-zone layout (>= threePaneMinWidth)', () {
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

      testWidgets('shows a vertical divider between findings and chat',
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
            ),
          ),
        );

        final divider = tester.widget<AppDivider>(find.byType(AppDivider));
        expect(divider.axis, Axis.vertical);
        expect(divider.color, isNull); // resolves to borderSubdued by default
      });

      testWidgets(
          'drawer is rendered inline (Scaffold.drawer is null) on wide',
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

      testWidgets('uses three-zone layout at threePaneMinWidth',
          (tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
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

    group('ultrawide: viewer and findings go side by side', () {
      testWidgets('sit side by side at ultrawideMinWidth', (tester) async {
        tester.view.physicalSize =
            const Size(AppLayout.ultrawideMinWidth * 3, 900 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const Text('viewer-content'),
              findingsPanel: const Text('findings-content'),
              chatPanel: const SizedBox(),
            ),
          ),
        );

        final viewerPos = tester.getTopLeft(find.text('viewer-content'));
        final findingsPos = tester.getTopLeft(find.text('findings-content'));
        expect(viewerPos.dx, isNot(closeTo(findingsPos.dx, 1)));
        expect(viewerPos.dy, closeTo(findingsPos.dy, 1));
      });

      testWidgets('still stack just under ultrawideMinWidth', (tester) async {
        const width = AppLayout.ultrawideMinWidth - 1;
        tester.view.physicalSize = const Size(width * 3, 900 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const Text('viewer-content'),
              findingsPanel: const Text('findings-content'),
              chatPanel: const SizedBox(),
            ),
          ),
        );

        final viewerPos = tester.getTopLeft(find.text('viewer-content'));
        final findingsPos = tester.getTopLeft(find.text('findings-content'));
        expect(viewerPos.dy, isNot(closeTo(findingsPos.dy, 1)));
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

    // DL §3.7 / D-004: the image slot is evidence surround, not page chrome.
    // It must be the diagnostic ground, and must not move with theme mode —
    // while the Scaffold around it stays themed, because that part IS chrome.
    group('diagnostic canvas ground', () {
      Future<ColoredBox> canvasFor(
        WidgetTester tester,
        Brightness brightness,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(brightness),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const Text('image'),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
            ),
          ),
        );
        return tester.widget<ColoredBox>(
          find
              .ancestor(
                of: find.text('image'),
                matching: find.byType(ColoredBox),
              )
              .first,
        );
      }

      testWidgets('image slot sits on canvasGround', (tester) async {
        final canvas = await canvasFor(tester, Brightness.light);
        expect(canvas.color, DiagnosticImageTokens.canvasGround);
        expect(canvas.color, isNot(AppColorsData.light.surfacePage));
      });

      testWidgets('is identical in light and dark', (tester) async {
        final light = await canvasFor(tester, Brightness.light);
        final dark = await canvasFor(tester, Brightness.dark);
        expect(light.color, dark.color);
      });

      testWidgets('the Scaffold around it stays themed, unlike the canvas',
          (tester) async {
        Future<Scaffold> scaffoldFor(Brightness brightness) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(brightness),
              home: StudyReviewTemplate(
                appBar: AppBar(),
                imageViewer: const SizedBox(),
                findingsPanel: const SizedBox(),
                chatPanel: const SizedBox(),
              ),
            ),
          );
          // Two pumps share one tester, so the second is a live light-to-dark
          // transition, not a fresh mount -- MaterialApp animates that theme
          // change, and a single frame lands mid-interpolation rather than at
          // the target color.
          await tester.pumpAndSettle();
          return tester.widget<Scaffold>(find.byType(Scaffold));
        }

        final light = await scaffoldFor(Brightness.light);
        expect(light.backgroundColor, AppColorsData.light.surfacePage);
        final dark = await scaffoldFor(Brightness.dark);
        expect(dark.backgroundColor, AppColorsData.dark.surfacePage);
        expect(dark.backgroundColor, isNot(light.backgroundColor));
      });
    });
  });
}
