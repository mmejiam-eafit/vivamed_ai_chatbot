import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/collapsed_nav_rail.dart';
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

    testWidgets('wide: drawer is inline and Scaffold.drawer is null',
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
            drawer: const Text('drawer-inline'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isNull);
      expect(find.text('drawer-inline'), findsOneWidget);
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
            chatPanel: const SizedBox(),
            findingsPanel: const SizedBox(),
            drawer: const SizedBox(),
          ),
        ),
      );

      final padded = tester.widget<Padding>(
        find
            .descendant(
                of: find.byType(ChatTemplate), matching: find.byType(Padding))
            .first,
      );
      final insets = padded.padding as EdgeInsets;
      expect(insets.left, AppSpacing.lg);
      expect(insets.top, AppSpacing.lg);

      final drawerSizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == NavigationTokens.sideNavWidth,
        ),
      );
      expect(drawerSizedBox.width, NavigationTokens.sideNavWidth);
    });
  });
}
