import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
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

      testWidgets(
          'narrow: primaryNavDrawer is ignored -- drawer (conversation '
          'history) still owns Scaffold.drawer', (tester) async {
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
              drawer: const Text('conversation-drawer-slot'),
              primaryNavDrawer: const Text('primary-nav-drawer-slot'),
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.drawer, isNotNull);
        expect(find.text('primary-nav-drawer-slot'), findsNothing);
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
          'drawerWide is rendered inline, drawer is ignored, no app bar',
          (tester) async {
        tester.view.physicalSize = const Size(1200 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(title: const Text('Study Review')),
              imageViewer: const SizedBox(),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
              drawer: const Text('drawer-narrow-only'),
              drawerWide: const Text('drawer-content-wide'),
            ),
          ),
        );
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        // Scaffold.drawer is the primary nav drawer slot (unset here, so
        // null) -- the conversation drawer renders inline regardless of it.
        expect(scaffold.drawer, isNull);
        expect(find.text('drawer-content-wide'), findsOneWidget);
        expect(find.text('drawer-narrow-only'), findsNothing);
        expect(scaffold.appBar, isNull);
        expect(find.text('Study Review'), findsNothing);
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

      testWidgets('primaryNavDrawer is wired as Scaffold.drawer',
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
              primaryNavDrawer: const Text('primary-nav-drawer-slot'),
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.drawer, isNotNull);
        // No app bar at this tier to show a DrawerButton in anymore -- the
        // menu trigger lives at the bottom of drawerWide instead.
        expect(scaffold.appBar, isNull);
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
              // Keyed so the padding assertion below can find its own
              // specific ancestor Padding -- ConversationDrawer's SafeArea
              // now also renders a Padding earlier in the tree (zero, from
              // the test's default MediaQuery), which "the first Padding
              // under the template" would otherwise match instead.
              imageViewer: const SizedBox(key: Key('image-viewer-placeholder')),
              findingsPanel: const SizedBox(),
              chatPanel: const SizedBox(),
              // A real ConversationDrawer, not a placeholder: the width
              // contract below is now the organism's own (isWide), not
              // something the template wraps it in.
              drawerWide:
                  const ConversationDrawer(conversations: [], isWide: true),
            ),
          ),
        );

        final padding = tester.widget<Padding>(
          find
              .ancestor(
                  of: find.byKey(const Key('image-viewer-placeholder')),
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

        final drawer = tester.widget<Drawer>(find.byType(Drawer));
        expect(drawer.width, NavigationTokens.sideNavWidth);
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
        expect(canvas.color, diagnosticCanvasGround);
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

    // ── Slots fill their cell ─────────────────────────────────────────────────
    //
    // A bare ColoredBox has no size of its own: it takes the smallest size its
    // constraints allow. That makes it show exactly what the template hands a
    // slot -- unlike Text or a real image, which size themselves and so hid a
    // loose cross-axis constraint that collapsed it to zero.
    group('slots fill their cell, whatever they hold', () {
      const imageKey = Key('image-slot');
      const findingsKey = Key('findings-slot');
      const chatKey = Key('chat-slot');

      Future<void> pumpAt(WidgetTester tester, double width) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: StudyReviewTemplate(
              appBar: AppBar(),
              imageViewer: const ColoredBox(key: imageKey, color: Colors.red),
              findingsPanel:
                  const ColoredBox(key: findingsKey, color: Colors.blue),
              chatPanel: const ColoredBox(key: chatKey, color: Colors.green),
            ),
          ),
        );
      }

      Size sizeOf(WidgetTester tester, Key key) =>
          tester.getSize(find.byKey(key));

      // Sizes here come from fractions (3 : 2), so compare with a tolerance.
      void expectSize(Size actual, Size expected) {
        expect(actual.width, closeTo(expected.width, 0.01));
        expect(actual.height, closeTo(expected.height, 0.01));
      }

      // The width left for the viewer and findings once the chat column and its
      // divider are taken out and the zone is padded by lg on each side.
      double primaryWidth(WidgetTester tester, double screen) =>
          screen -
          AppLayout.panelMaxWidth -
          tester.getSize(find.byType(AppDivider)).width -
          2 * AppSpacing.lg;

      testWidgets('three-zone: viewer over findings, 3 : 2, both full width',
          (tester) async {
        await pumpAt(tester, 1280);

        final width = primaryWidth(tester, 1280);
        // No app bar at this tier: the zone is 900 tall, padded by lg, and the
        // two slots share what is left after an lg gap, 3 : 2.
        const shared = 900 - 2 * AppSpacing.lg - AppSpacing.lg;
        expectSize(sizeOf(tester, imageKey), Size(width, shared * 3 / 5));
        expectSize(sizeOf(tester, findingsKey), Size(width, shared * 2 / 5));
        expectSize(
            sizeOf(tester, chatKey), const Size(AppLayout.panelMaxWidth, 900));
      });

      testWidgets('ultrawide: viewer beside findings, 3 : 2, both full height',
          (tester) async {
        await pumpAt(tester, 1920);

        final shared = primaryWidth(tester, 1920) - AppSpacing.lg;
        const height = 900 - 2 * AppSpacing.lg;
        expectSize(sizeOf(tester, imageKey), Size(shared * 3 / 5, height));
        expectSize(sizeOf(tester, findingsKey), Size(shared * 2 / 5, height));
        expectSize(
            sizeOf(tester, chatKey), const Size(AppLayout.panelMaxWidth, 900));
      });

      testWidgets('viewer + tabs: the viewer fills its column', (tester) async {
        await pumpAt(tester, 1000);

        // 3 of 5 parts of the width, lg padding on every side, under the app bar.
        expectSize(
            sizeOf(tester, imageKey),
            const Size(1000 * 3 / 5 - 2 * AppSpacing.lg,
                900 - kToolbarHeight - 2 * AppSpacing.lg));
        expect(sizeOf(tester, findingsKey).width, 1000 * 2 / 5);
      });

      testWidgets('narrow: viewer keeps its 4:3 box, findings fill the tab',
          (tester) async {
        // Not changed by the stretch fix -- pinned so it stays that way.
        await pumpAt(tester, 390);

        expectSize(sizeOf(tester, imageKey), const Size(390, 390 * 3 / 4));
        expect(sizeOf(tester, findingsKey).width, 390);
      });
    });
  });
}
