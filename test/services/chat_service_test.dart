import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/services/chat_service.dart';

class _FakeConversationRepository implements ConversationRepository {
  String? lastMessagesFor;

  @override
  Future<List<ConversationItem>> getConversations() async => const [
        ConversationItem(id: 'c1', title: 'T', subtitle: 'S'),
      ];

  @override
  Future<List<ChatMessageItem>> getMessages(String conversationId) async {
    lastMessagesFor = conversationId;
    return const [ChatMessageItem(id: 'm1', message: 'hi', isUser: true)];
  }

  @override
  Future<ChatMessageItem> sendMessage({
    required String conversationId,
    required String text,
  }) =>
      throw UnimplementedError();
}

class _FakeChatStreamRepository implements ChatStreamRepository {
  String? lastConversationId;
  List<ChatMessageItem>? lastMessages;

  @override
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  }) {
    lastConversationId = conversationId;
    lastMessages = messages;
    return Stream.value(
      const ChatMessageItem(id: 'a1', message: 'reply', isUser: false),
    );
  }
}

void main() {
  test('getConversations and getMessages go to the conversation repository',
      () async {
    final conversations = _FakeConversationRepository();
    final service = ChatService(conversations, _FakeChatStreamRepository());

    expect((await service.getConversations()).single.id, 'c1');
    expect((await service.getMessages('conv-9')).single.id, 'm1');
    expect(conversations.lastMessagesFor, 'conv-9');
  });

  test('streamReply hands the conversation and thread to the stream repository',
      () async {
    final stream = _FakeChatStreamRepository();
    final service = ChatService(_FakeConversationRepository(), stream);
    const thread = [ChatMessageItem(id: 'u1', message: 'q', isUser: true)];

    final snapshots = await service.streamReply('conv-9', thread).toList();

    expect(stream.lastConversationId, 'conv-9');
    expect(stream.lastMessages, same(thread));
    expect(snapshots.single.id, 'a1');
  });
}
