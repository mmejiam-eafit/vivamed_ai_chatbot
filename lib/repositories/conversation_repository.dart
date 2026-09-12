import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/mocks/conversation_mocks.dart';

abstract class ConversationRepository {
  Future<List<ConversationItem>> getConversations();
  Future<List<ChatMessageItem>> getMessages(String conversationId);

  /// Returns the persisted user message only -- no simulated AI reply.
  /// Authoring a canned assistant response is a content decision, not a
  /// data-layer one; it slots in easily here later.
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  });
}

class MockConversationRepository implements ConversationRepository {
  @override
  Future<List<ConversationItem>> getConversations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockConversations;
  }

  @override
  Future<List<ChatMessageItem>> getMessages(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockMessagesFor(conversationId);
  }

  @override
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return addMockMessage(conversationId, text);
  }
}
