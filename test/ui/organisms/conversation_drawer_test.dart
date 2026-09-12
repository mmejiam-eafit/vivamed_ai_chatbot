import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: child),
      );

  const conversations = [
    ConversationItem(id: '1', title: 'Chest CT — Patient A', subtitle: '2h ago'),
    ConversationItem(id: '2', title: 'Abdominal MRI — Patient B', subtitle: 'Yesterday'),
  ];

  // ── Structure ──────────────────────────────────────────────────────────────

  testWidgets('renders every conversation title', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(
      conversations: conversations,
    )));
    expect(find.text('Chest CT — Patient A'), findsOneWidget);
    expect(find.text('Abdominal MRI — Patient B'), findsOneWidget);
  });

  testWidgets('empty state message shown when there are no conversations',
      (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(conversations: [])));
    expect(find.text('No conversations yet.'), findsOneWidget);
  });

  testWidgets('renders the user name in the header', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(
      conversations: [],
      userName: 'Dr. Ramirez',
    )));
    expect(find.text('Dr. Ramirez'), findsOneWidget);
  });

  testWidgets('defaults to "Radiologist" when userName is null', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(conversations: [])));
    expect(find.text('Radiologist'), findsOneWidget);
  });

  testWidgets('renders a Settings nav item', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(conversations: [])));
    expect(find.text('Settings'), findsOneWidget);
  });

  // ── Callbacks ──────────────────────────────────────────────────────────────

  testWidgets('onSelect fires with the tapped conversation id', (tester) async {
    String? selected;
    await tester.pumpWidget(wrap(ConversationDrawer(
      conversations: conversations,
      onSelect: (id) => selected = id,
    )));
    await tester.tap(find.text('Abdominal MRI — Patient B'));
    await tester.pump();
    expect(selected, '2');
  });

  testWidgets('onSettings fires on tap', (tester) async {
    var called = false;
    await tester.pumpWidget(wrap(ConversationDrawer(
      conversations: const [],
      onSettings: () => called = true,
    )));
    await tester.tap(find.text('Settings'));
    await tester.pump();
    expect(called, isTrue);
  });

  // ── Selected state ─────────────────────────────────────────────────────────

  testWidgets('selected tile carries a highlighted background', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(
      conversations: conversations,
      selectedId: '1',
    )));
    final tiles = tester.widgetList<Container>(find.descendant(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    expect(tiles.any((c) => c.color == AppColorsData.light.surfaceBrandSecondarySubdued),
        isTrue);
  });

  // ── Width (DT §9.3 / gap 25) ───────────────────────────────────────────────

  testWidgets('drawer width reads NavigationTokens.drawerWidth, not a literal',
      (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(conversations: [])));
    final drawer = tester.widget<Drawer>(find.byType(Drawer));
    expect(drawer.width, NavigationTokens.drawerWidth);
    expect(tester.getSize(find.byType(Drawer)).width, NavigationTokens.drawerWidth);
  });

  // ── Text scale (DT §3.7 / gap 20b) ─────────────────────────────────────────

  testWidgets('header username, tile title, and subtitle allow 2 lines, not 1',
      (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(
      conversations: conversations,
      userName: 'Dr. Ramirez',
    )));
    final username = tester.widget<Text>(find.text('Dr. Ramirez'));
    expect(username.maxLines, 2);
    final title = tester.widget<Text>(find.text('Chest CT — Patient A'));
    expect(title.maxLines, 2);
    final subtitle = tester.widget<Text>(find.text('2h ago'));
    expect(subtitle.maxLines, 2);
  });

  // ── Hover (gap 23) ─────────────────────────────────────────────────────────

  testWidgets('conversation tile hovers with sideNavHoverColor', (tester) async {
    await tester.pumpWidget(wrap(const ConversationDrawer(
      conversations: conversations,
    )));
    final inkWell = tester.widget<InkWell>(find.ancestor(
      of: find.text('Chest CT — Patient A'),
      matching: find.byType(InkWell),
    ));
    expect(inkWell.hoverColor, NavigationTokens.sideNavHoverColor);
  });

  // ── Dark theme ─────────────────────────────────────────────────────────────

  testWidgets('resolves against the dark theme', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(Brightness.dark),
      home: const Scaffold(
        body: ConversationDrawer(conversations: conversations, selectedId: '1'),
      ),
    ));
    final drawer = tester.widget<Drawer>(find.byType(Drawer));
    expect(drawer.backgroundColor, AppColorsData.dark.surfaceBrandSecondary);

    final username = tester.widget<Text>(find.text('Radiologist'));
    expect(username.style?.color, AppColorsData.dark.textOnBrand);

    final tiles = tester.widgetList<Container>(find.descendant(
      of: find.byType(InkWell),
      matching: find.byType(Container),
    ));
    expect(
      tiles.any((c) => c.color == AppColorsData.dark.surfaceBrandSecondarySubdued),
      isTrue,
    );
  });
}
