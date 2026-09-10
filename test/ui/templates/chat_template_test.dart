import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
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
      expect(scaffold.backgroundColor, AppColors.surfacePage);
    });

    testWidgets('narrow layout renders findings as bottom sheet',
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
      expect(scaffold.bottomSheet, isNotNull);
      expect(find.text('findings'), findsOneWidget);
    });

    testWidgets('narrow layout has no bottom sheet when findings null',
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
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
    });

    testWidgets('wide layout renders findings inline side panel',
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
            findingsPanel: const Text('findings-side'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNull);
      expect(find.text('findings-side'), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
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

    testWidgets('drawer is inline and Scaffold.drawer is null on wide',
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

    testWidgets('uses narrow layout below threePaneMinWidth', (tester) async {
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

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomSheet, isNotNull);
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
