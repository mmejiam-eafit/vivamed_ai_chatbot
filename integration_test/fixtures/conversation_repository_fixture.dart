import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';

import 'fixture_result.dart';

/// Mutable -- a test can reassign a result between calls without
/// re-overriding the provider.
class ConversationRepositoryFixture implements ConversationRepository {
  ConversationRepositoryFixture({
    this.getConversationsResult,
    this.getMessagesResult,
    this.sendMessageResult,
  });

  FixtureResult<List<ConversationItem>>? getConversationsResult;
  FixtureResult<List<ChatMessageItem>>? getMessagesResult;
  FixtureResult<ChatMessageItem>? sendMessageResult;

  @override
  Future<List<ConversationItem>> getConversations() =>
      getConversationsResult?.resolve() ?? _unconfigured('getConversations');

  @override
  Future<List<ChatMessageItem>> getMessages(String conversationId) =>
      getMessagesResult?.resolve() ?? _unconfigured('getMessages');

  @override
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      sendMessageResult?.resolve() ?? _unconfigured('sendMessage');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'ConversationRepositoryFixture.$method not configured for this test');
