import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';

import 'fixtures/chat_stream_repository_fixture.dart';
import 'fixtures/conversation_repository_fixture.dart';
import 'fixtures/fixture_result.dart';
import 'fixtures/user_repository_fixture.dart';

/// Fixture-backed scenarios: success path and loading only. The error
/// branches are covered by `test/ui/pages/chat_page_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Wide tier so ConversationDrawer renders inline (drawerWide) instead of
  // behind an unopened Scaffold.drawer -- matches chat_page_test.dart's own
  // convention for these same assertions.
  void setWideSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  const fixtureConversations = [
    ConversationItem(
        id: 'fixture-conv-1', title: 'Fixture Conversation', subtitle: 'now'),
  ];

  testWidgets('success renders fixture conversations and messages',
      (tester) async {
    setWideSize(tester);
    final conversationFixture = ConversationRepositoryFixture(
      getConversationsResult: const FixtureSuccess(fixtureConversations),
      getMessagesResult: const FixtureSuccess([
        ChatMessageItem(id: 'fixture-msg', message: 'Fixture message', isUser: false),
      ]),
    );
    final userFixture = UserRepositoryFixture(
      getCurrentUserResult: const FixtureSuccess(UserProfile(
        name: 'Fixture User',
        role: 'Fixture Role',
        email: 'fixture@example.invalid',
        initials: 'FU',
      )),
    );
    await tester.pumpWidget(wrap(
      const ChatPage(),
      overrides: [
        conversationRepositoryProvider.overrideWithValue(conversationFixture),
        userRepositoryProvider.overrideWithValue(userFixture),
      ],
    ));
    await tester.pumpAndSettle();

    final drawer =
        tester.widget<ConversationDrawer>(find.byType(ConversationDrawer));
    expect(drawer.selectedId, 'fixture-conv-1');
    expect(find.text('Fixture Conversation'), findsOneWidget);
    expect(find.text('Fixture message'), findsOneWidget);
  });

  testWidgets('sending a message streams the fixture reply into the list',
      (tester) async {
    setWideSize(tester);
    final conversationFixture = ConversationRepositoryFixture(
      getConversationsResult: const FixtureSuccess(fixtureConversations),
      getMessagesResult: const FixtureSuccess([
        ChatMessageItem(id: 'fixture-msg', message: 'Fixture message', isUser: false),
      ]),
    );
    final userFixture = UserRepositoryFixture(
      getCurrentUserResult: const FixtureSuccess(UserProfile(
        name: 'Fixture User',
        role: 'Fixture Role',
        email: 'fixture@example.invalid',
        initials: 'FU',
      )),
    );
    final streamFixture = ChatStreamRepositoryFixture(snapshots: const [
      ChatMessageItem(
        id: 'fixture-reply',
        message: '',
        isUser: false,
        status: ChatMessageStatus.streaming,
      ),
      ChatMessageItem(
        id: 'fixture-reply',
        message: 'Fixture reply',
        isUser: false,
        status: ChatMessageStatus.streaming,
      ),
      ChatMessageItem(id: 'fixture-reply', message: 'Fixture reply', isUser: false),
    ]);
    await tester.pumpWidget(wrap(
      const ChatPage(),
      overrides: [
        conversationRepositoryProvider.overrideWithValue(conversationFixture),
        userRepositoryProvider.overrideWithValue(userFixture),
        chatStreamRepositoryProvider.overrideWithValue(streamFixture),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Fixture question');
    await tester.tap(find.byIcon(Icons.send));
    // Settles: the scripted stream finishes at once, so the typing dots are
    // gone by the end and nothing is left animating.
    await tester.pumpAndSettle();

    expect(streamFixture.lastConversationId, 'fixture-conv-1');
    expect(streamFixture.lastMessages!.last.message, 'Fixture question');
    expect(find.text('Fixture question'), findsOneWidget);
    expect(find.text('Fixture reply'), findsOneWidget);
    expect(find.text('Reply failed'), findsNothing);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    setWideSize(tester);
    final conversationFixture = ConversationRepositoryFixture(
      getConversationsResult: const FixturePending(),
    );
    final userFixture = UserRepositoryFixture(
      getCurrentUserResult: const FixturePending(),
    );
    await tester.pumpWidget(wrap(
      const ChatPage(),
      overrides: [
        conversationRepositoryProvider.overrideWithValue(conversationFixture),
        userRepositoryProvider.overrideWithValue(userFixture),
      ],
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });
}
