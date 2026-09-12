import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';

class ChatService {
  ChatService(this._conversationRepository);

  final ConversationRepository _conversationRepository;

  Future<List<ConversationItem>> getConversations() =>
      _conversationRepository.getConversations();

  Future<List<ChatMessageItem>> getMessages(String conversationId) =>
      _conversationRepository.getMessages(conversationId);

  Future<ChatMessageItem> sendMessage(String conversationId, String text) =>
      _conversationRepository.sendMessage(
        conversationId: conversationId,
        text: text,
      );
}
