import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/mocks/conversation_mocks.dart';

/// Why a reply could not be completed: a non-2xx response, an `error` or
/// `abort` chunk, or a stream that ended before it finished.
class ChatStreamException implements Exception {
  const ChatStreamException(this.message, {this.statusCode});

  final String message;

  /// The HTTP status when the request itself was rejected; null for a failure
  /// that happened mid-stream.
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'ChatStreamException: $message'
      : 'ChatStreamException: $message (HTTP $statusCode)';
}

abstract class ChatStreamRepository {
  /// One call both sends the user's message and streams the assistant's reply
  /// -- the shape of the backend's single streaming POST. [messages] is the
  /// whole thread so far with the new user message **last**; the backend is
  /// stateless and is handed the history every time.
  ///
  /// Emits snapshots of the assistant message: always the same `id`, `message`
  /// growing, `status: streaming`, and a final `complete` snapshot. A failure
  /// is a stream error ([ChatStreamException]), not a snapshot -- the caller
  /// decides how to show it.
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  });
}

class MockChatStreamRepository implements ChatStreamRepository {
  @override
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  }) async* {
    // Persisted up front, as a backend would on receiving the request.
    appendMockMessage(conversationId, messages.last);
    final id = '$conversationId-msg-${mockMessagesFor(conversationId).length + 1}';

    // The dots phase: the reply exists but has no text yet.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    yield ChatMessageItem(
      id: id,
      message: '',
      isUser: false,
      status: ChatMessageStatus.streaming,
    );

    var text = '';
    for (final word in mockAssistantReply.split(' ')) {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      text = text.isEmpty ? word : '$text $word';
      yield ChatMessageItem(
        id: id,
        message: text,
        isUser: false,
        status: ChatMessageStatus.streaming,
      );
    }

    final complete = ChatMessageItem(id: id, message: text, isUser: false);
    appendMockMessage(conversationId, complete);
    yield complete;
  }
}
