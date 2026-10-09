import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/collapsed_nav_rail.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/draggable_findings_sheet.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

void main() {
  group('ChatTemplate', () {
    testWidgets('renders appBar and chatPanel slots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(title: const Text('Chat')),
            chatPanel: const Text('chat-panel'),
          ),
        ),
      );

      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('chat-panel'), findsOneWidget);
    });

    testWidgets('renders statusBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            statusBar: const Text('status'),
          ),
        ),
      );

      expect(find.text('status'), findsOneWidget);
    });

    testWidgets('uses surfacePage scaffold background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
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
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColorsData.dark.surfacePage);
    });

    // ── Compact (< mediumMinWidth): drawer + draggable bottom sheet ────────

    testWidgets('compact: renders findings as a draggable bottom sheet',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isA<DraggableFindingsSheet>());
      expect(find.text('findings'), findsOneWidget);
    });

    testWidgets(
        'compact: bottom sheet gets the available height, not a fixed pixel '
        'value', (tester) async {
      // Regression guard for gap 25: the sheet used to be capped at the
      // literal AppLayout.panelMaxWidth (a width constant) treated as a
      // height, so it never changed with the screen.
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(390 * 3, 700 * 3);
      tester.view.devicePixelRatio = 3.0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final sheet = scaffold.bottomSheet! as DraggableFindingsSheet;
      // The outer LayoutBuilder measures ChatTemplate's own incoming
      // constraints -- the full view height, since the AppBar it hands to
      // Scaffold is built underneath this point, not above it.
      expect(sheet.availableHeight, 700);
    });

    testWidgets('compact: no bottom sheet when findings null', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(appBar: AppBar(), chatPanel: const SizedBox()),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
    });

    testWidgets('compact: drawer is passed to Scaffold.drawer', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            drawer: const Text('drawer-slot'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
    });

    // ── Medium (mediumMinWidth to threePaneMinWidth): collapsed rail ───────

    testWidgets('medium: renders CollapsedNavRail at sideNavCollapsedWidth',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            drawer: const Text('drawer-slot'),
            findingsPanel: const Text('findings-slot'),
          ),
        ),
      );

      expect(find.byType(CollapsedNavRail), findsOneWidget);
      final size = tester.getSize(find.byType(CollapsedNavRail));
      expect(size.width, NavigationTokens.sideNavCollapsedWidth);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
      expect(scaffold.drawer, isNotNull);
      expect(scaffold.endDrawer, isNotNull);
    });

    testWidgets('medium: tapping the menu icon opens Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            drawer: const Text('drawer-slot'),
          ),
        ),
      );

      final state = tester.state<ScaffoldState>(find.byType(Scaffold));
      expect(state.isDrawerOpen, isFalse);
      await tester.tap(find.byTooltip('Conversations'));
      await tester.pumpAndSettle();
      expect(state.isDrawerOpen, isTrue);
    });

    testWidgets('medium: tapping the findings icon opens Scaffold.endDrawer',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings-slot'),
          ),
        ),
      );

      final state = tester.state<ScaffoldState>(find.byType(Scaffold));
      expect(state.isEndDrawerOpen, isFalse);
      await tester.tap(find.byTooltip('Findings'));
      await tester.pumpAndSettle();
      expect(state.isEndDrawerOpen, isTrue);
      expect(find.text('findings-slot'), findsOneWidget);
    });

    testWidgets('medium: no findings icon or endDrawer when findings null',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(appBar: AppBar(), chatPanel: const SizedBox()),
        ),
      );

      expect(find.byTooltip('Findings'), findsNothing);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.endDrawer, isNull);
    });

    // ── Wide (>= threePaneMinWidth): three panes ────────────────────────────

    testWidgets('wide: renders findings inline side panel', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings-side'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
      expect(find.text('findings-side'), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('wide: drawerWide is inline, drawer is ignored, no app bar',
        (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(title: const Text('Chat')),
            chatPanel: const SizedBox(),
            drawer: const Text('drawer-narrow-only'),
            drawerWide: const Text('drawer-inline-wide'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      // Scaffold.drawer is the primary nav drawer slot (unset here, so
      // null) -- the conversation drawer renders inline regardless of it.
      expect(scaffold.drawer, isNull);
      expect(find.text('drawer-inline-wide'), findsOneWidget);
      expect(find.text('drawer-narrow-only'), findsNothing);
      expect(scaffold.appBar, isNull);
      expect(find.text('Chat'), findsNothing);
    });

    // ── Tier boundaries ─────────────────────────────────────────────────────

    testWidgets('uses compact layout below mediumMinWidth', (tester) async {
      const width = AppLayout.mediumMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNotNull);
      expect(find.byType(CollapsedNavRail), findsNothing);
    });

    testWidgets('uses rail layout at mediumMinWidth', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
      expect(find.byType(CollapsedNavRail), findsOneWidget);
    });

    testWidgets('uses rail layout below threePaneMinWidth', (tester) async {
      const width = AppLayout.threePaneMinWidth - 1;
      tester.view.physicalSize = const Size(width * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      expect(find.byType(CollapsedNavRail), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses wide layout at threePaneMinWidth', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.threePaneMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            findingsPanel: const Text('findings'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
      expect(find.byType(CollapsedNavRail), findsNothing);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('applies expected template spacing contracts', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            // Keyed so the padding assertion below can find its own specific
            // ancestor Padding -- ConversationDrawer's SafeArea now also
            // renders a Padding earlier in the tree (zero, from the test's
            // default MediaQuery), which "the first Padding under the
            // template" would otherwise match instead.
            chatPanel: const SizedBox(key: Key('chat-panel-placeholder')),
            findingsPanel: const SizedBox(),
            // A real ConversationDrawer, not a placeholder: the width
            // contract below is now the organism's own (isWide), not
            // something the template wraps it in.
            drawerWide:
                const ConversationDrawer(conversations: [], isWide: true),
          ),
        ),
      );

      final padded = tester.widget<Padding>(
        find
            .ancestor(
                of: find.byKey(const Key('chat-panel-placeholder')),
                matching: find.byType(Padding))
            .first,
      );
      final insets = padded.padding as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.width, NavigationTokens.sideNavWidth);
    });

    // ── navBar slot ──────────────────────────────────────────────────────

    testWidgets('compact: navBar is passed to Scaffold.bottomNavigationBar',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(find.text('nav-bar-slot'), findsOneWidget);
    });

    testWidgets('rail: navBar is passed to Scaffold.bottomNavigationBar',
        (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );

      expect(find.text('nav-bar-slot'), findsOneWidget);
    });

    testWidgets(
        'wide: navBar is NOT shown even when provided -- primaryNavDrawer '
        'replaces it', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            navBar: const Text('nav-bar-slot'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
      expect(find.text('nav-bar-slot'), findsNothing);
    });

    testWidgets('wide: primaryNavDrawer is wired as Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNotNull);
      // No app bar at this tier to show a DrawerButton in anymore -- the
      // menu trigger lives at the bottom of drawerWide/menuRail instead.
      expect(scaffold.appBar, isNull);
    });

    testWidgets('compact/rail: primaryNavDrawer is ignored, navBar still shows',
        (tester) async {
      // Below the wide tier, primaryNavDrawer isn't wired to anything --
      // navBar keeps rendering exactly as before this change.
      tester.view.physicalSize =
          const Size(AppLayout.mediumMinWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(
            appBar: AppBar(),
            chatPanel: const SizedBox(),
            navBar: const Text('nav-bar-slot'),
            primaryNavDrawer: const Text('primary-nav-drawer-slot'),
          ),
        ),
      );

      expect(find.text('nav-bar-slot'), findsOneWidget);
      expect(find.text('primary-nav-drawer-slot'), findsNothing);
    });

    testWidgets('navBar is absent when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: ChatTemplate(appBar: AppBar(), chatPanel: const SizedBox()),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    });

    // ── Slots fill their cell ─────────────────────────────────────────────────
    //
    // A bare ColoredBox has no size of its own: it takes the smallest size its
    // constraints allow. That makes it show exactly what the template hands a
    // slot -- unlike Text or a ListView, which size themselves and so hid a
    // loose cross-axis constraint that collapsed it to zero.
    group('slots fill their cell, whatever they hold', () {
      const chatKey = Key('chat-slot');
      const findingsKey = Key('findings-slot');

      Future<void> pumpAt(WidgetTester tester, double width) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: buildAppTheme(),
            home: ChatTemplate(
              appBar: AppBar(),
              chatPanel: const ColoredBox(key: chatKey, color: Colors.red),
              findingsPanel:
                  const ColoredBox(key: findingsKey, color: Colors.blue),
            ),
          ),
        );
      }

      Size sizeOf(WidgetTester tester, Key key) =>
          tester.getSize(find.byKey(key));

      testWidgets('wide: chat fills the column beside the findings panel',
          (tester) async {
        await pumpAt(tester, 1280);

        // Row: chat column (the rest) | findings (panelMaxWidth). No app bar
        // here, so the body is the full 900px; the chat column pads by lg.
        expect(
          sizeOf(tester, chatKey),
          const Size(1280 - AppLayout.panelMaxWidth - 2 * AppSpacing.lg,
              900 - 2 * AppSpacing.lg),
        );
        expect(sizeOf(tester, findingsKey),
            const Size(AppLayout.panelMaxWidth, 900));
      });

      testWidgets('medium: chat fills the space beside the collapsed rail',
          (tester) async {
        await pumpAt(tester, 800);

        // App bar on top (kToolbarHeight), the 64px rail on the left, lg
        // padding around the chat column. Findings are an end drawer here, so
        // not on screen until opened.
        expect(
          sizeOf(tester, chatKey),
          const Size(
              800 - NavigationTokens.sideNavCollapsedWidth - 2 * AppSpacing.lg,
              900 - kToolbarHeight - 2 * AppSpacing.lg),
        );
        expect(find.byKey(findingsKey), findsNothing);
      });

      testWidgets(
          'compact: chat fills the body, findings fill the sheet\'s width',
          (tester) async {
        await pumpAt(tester, 390);

        expect(sizeOf(tester, chatKey), const Size(390, 900 - kToolbarHeight));
        // The findings sheet is as wide as the screen; its height follows the
        // drag position, so only that it has some is asserted.
        final findings = sizeOf(tester, findingsKey);
        expect(findings.width, 390);
        expect(findings.height, greaterThan(0));
      });
    });
  });
}
