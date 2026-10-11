import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';

void main() {
  group('ChatMessageItem', () {
    test('keeps the id it is given', () {
      const item = ChatMessageItem(id: 'm1', message: 'hi', isUser: true);
      expect(item.id, 'm1');
    });

    test('status defaults to complete', () {
      const item = ChatMessageItem(id: 'm1', message: 'hi', isUser: true);
      expect(item.status, ChatMessageStatus.complete);
    });

    for (final status in ChatMessageStatus.values) {
      test('holds status ${status.name}', () {
        final item = ChatMessageItem(
          id: 'm1',
          message: 'hi',
          isUser: false,
          status: status,
        );
        expect(item.status, status);
      });
    }

    group('copyWith', () {
      const original = ChatMessageItem(
        id: 'placeholder',
        message: 'He',
        isUser: false,
        status: ChatMessageStatus.streaming,
        avatarImageUrl: 'https://example.com/a.png',
        avatarInitials: 'AI',
        timestamp: '09:14',
        caseReferences: [CaseReference(caseId: 'case-1', title: 'Chest X-Ray')],
      );

      test('replaces the id', () {
        expect(original.copyWith(id: 'server-id').id, 'server-id');
      });

      test('replaces the message', () {
        expect(original.copyWith(message: 'Hello').message, 'Hello');
      });

      test('replaces the status', () {
        expect(
          original.copyWith(status: ChatMessageStatus.failed).status,
          ChatMessageStatus.failed,
        );
      });

      test('with no arguments keeps every field', () {
        final copy = original.copyWith();
        expect(copy.id, original.id);
        expect(copy.message, original.message);
        expect(copy.status, original.status);
      });

      test('never touches the fields a stream does not change', () {
        final copy = original.copyWith(
          id: 'server-id',
          message: 'Hello',
          status: ChatMessageStatus.complete,
        );
        expect(copy.isUser, original.isUser);
        expect(copy.avatarImageUrl, original.avatarImageUrl);
        expect(copy.avatarInitials, original.avatarInitials);
        expect(copy.timestamp, original.timestamp);
        expect(copy.caseReferences, same(original.caseReferences));
      });
    });
  });
}
