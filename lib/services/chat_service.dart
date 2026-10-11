import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';

class ChatService {
  ChatService(this._conversationRepository, this._chatStreamRepository);

  final ConversationRepository _conversationRepository;
  final ChatStreamRepository _chatStreamRepository;

  Future<List<ConversationItem>> getConversations() =>
      _conversationRepository.getConversations();

  Future<List<ChatMessageItem>> getMessages(String conversationId) =>
      _conversationRepository.getMessages(conversationId);

  @Deprecated(
    'Superseded by streamReply. Remove together with '
    'ConversationRepository.sendMessage once the backend\'s streaming POST is '
    'live.',
  )
  Future<ChatMessageItem> sendMessage(String conversationId, String text) =>
      _conversationRepository.sendMessage(
        conversationId: conversationId,
        text: text,
      );

  /// [messages] is the whole thread with the new user message last.
  Stream<ChatMessageItem> streamReply(
    String conversationId,
    List<ChatMessageItem> messages,
  ) =>
      _chatStreamRepository.streamReply(
        conversationId: conversationId,
        messages: messages,
      );
}
