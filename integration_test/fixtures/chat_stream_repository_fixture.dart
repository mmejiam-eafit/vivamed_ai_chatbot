import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';

/// Replays a scripted reply -- [snapshots] in order, then the stream closes --
/// and records what it was asked to send. Mutable, like the other fixtures.
///
/// Unlike them it has no pending/failure results: the scripted snapshots stand
/// in for a stream, and the failure branches are covered by
/// `test/ui/pages/chat_page_test.dart`.
class ChatStreamRepositoryFixture implements ChatStreamRepository {
  ChatStreamRepositoryFixture({this.snapshots = const []});

  List<ChatMessageItem> snapshots;
  String? lastConversationId;
  List<ChatMessageItem>? lastMessages;

  @override
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  }) async* {
    lastConversationId = conversationId;
    lastMessages = messages;
    for (final snapshot in snapshots) {
      yield snapshot;
    }
  }
}
