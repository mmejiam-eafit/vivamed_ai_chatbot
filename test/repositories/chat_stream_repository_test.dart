import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/mocks/conversation_mocks.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';

void main() {
  group('ChatStreamException', () {
    test('toString carries the message', () {
      expect(
        const ChatStreamException('boom').toString(),
        'ChatStreamException: boom',
      );
    });

    test('toString carries the HTTP status when there is one', () {
      expect(
        const ChatStreamException('nope', statusCode: 422).toString(),
        'ChatStreamException: nope (HTTP 422)',
      );
    });
  });

  // The mock's delays are real time (~1s a stream), so each conversation is
  // streamed once and the tests below read from that one run.
  group('MockChatStreamRepository', () {
    const conversationId = 'stream-test-full';
    const question = ChatMessageItem(
      id: 'user-1',
      message: 'Any effusion?',
      isUser: true,
    );
    late List<ChatMessageItem> snapshots;

    setUpAll(() async {
      snapshots = await MockChatStreamRepository()
          .streamReply(conversationId: conversationId, messages: [question])
          .toList();
    });

    test('opens with an empty streaming reply -- the typing-dots phase', () {
      expect(snapshots.first.message, isEmpty);
      expect(snapshots.first.status, ChatMessageStatus.streaming);
    });

    test('every snapshot is the same assistant message', () {
      expect(snapshots.map((s) => s.id).toSet(), hasLength(1));
      expect(snapshots.every((s) => !s.isUser), isTrue);
    });

    test('the text only ever grows', () {
      for (var i = 1; i < snapshots.length; i++) {
        expect(
          snapshots[i].message.startsWith(snapshots[i - 1].message),
          isTrue,
          reason: 'snapshot $i should extend snapshot ${i - 1}',
        );
      }
      expect(snapshots.length, greaterThan(3));
    });

    test('only the last snapshot is complete, and it holds the whole reply', () {
      expect(snapshots.last.status, ChatMessageStatus.complete);
      expect(snapshots.last.message, mockAssistantReply);
      expect(
        snapshots.take(snapshots.length - 1).map((s) => s.status),
        everyElement(ChatMessageStatus.streaming),
      );
    });

    test('persists the question and the reply, so a refetch agrees', () {
      final stored = mockMessagesFor(conversationId);
      expect(stored.map((m) => m.id), [question.id, snapshots.last.id]);
      expect(stored.last.message, mockAssistantReply);
    });

    test('the reply id never collides with the question id', () {
      expect(snapshots.last.id, isNot(question.id));
    });

    test('cancelling mid-stream keeps the question but not the reply', () async {
      const id = 'stream-test-cancel';
      await MockChatStreamRepository()
          .streamReply(conversationId: id, messages: [question])
          .first;

      expect(mockMessagesFor(id).map((m) => m.id), [question.id]);
    });
  });
}
