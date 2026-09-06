import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

void main() {
  group('ChatPage', () {
    testWidgets('renders ChatTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      expect(find.byType(ChatTemplate), findsOneWidget);
    });

    testWidgets('renders Chat in app bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      expect(find.text('Chat'), findsOneWidget);
    });

    testWidgets('renders ChatPanel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      expect(find.byType(ChatPanel), findsOneWidget);
    });

    testWidgets('renders FindingsPanel slot', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      expect(find.byType(FindingsPanel), findsOneWidget);
    });

    // ── Responsive breakpoint: 767 (narrow) ──────────────────────────────────

    testWidgets('narrow at 767: drawer assigned to Scaffold.drawer',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNotNull);
    });

    testWidgets('narrow at 767: findings rendered as bottom sheet',
        (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth - 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomSheet, isNotNull);
    });

    // ── Responsive breakpoint: 768 (wide — at split) ─────────────────────────

    testWidgets('wide at 768: Scaffold.drawer is null', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNull);
    });

    testWidgets('wide at 768: findings inline — no bottom sheet', (tester) async {
      tester.view.physicalSize =
          const Size(AppLayout.templateSplitWidth * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomSheet, isNull);
    });

    // ── Responsive breakpoint: 769 (wide — above split) ──────────────────────

    testWidgets('wide at 769: drawer is inline and Row is used', (tester) async {
      tester.view.physicalSize =
          const Size((AppLayout.templateSplitWidth + 1) * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.drawer, isNull);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('renders ConversationDrawer slot', (tester) async {
      tester.view.physicalSize = const Size(1200 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: const ChatPage()),
      );

      expect(find.byType(ConversationDrawer), findsOneWidget);
    });
  });
}
