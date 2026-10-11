import 'dart:async';

import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';

/// A [ChatStreamRepository] the test drives by hand: each `streamReply` call
/// hands back a stream whose controller is [latest], so the test decides when
/// snapshots, errors and completion arrive -- no timers, no real HTTP.
class FakeChatStreamRepository implements ChatStreamRepository {
  final controllers = <StreamController<ChatMessageItem>>[];
  var cancelCount = 0;
  String? lastConversationId;
  List<ChatMessageItem>? lastMessages;

  StreamController<ChatMessageItem> get latest => controllers.last;

  @override
  Stream<ChatMessageItem> streamReply({
    required String conversationId,
    required List<ChatMessageItem> messages,
  }) {
    lastConversationId = conversationId;
    lastMessages = messages;
    final controller = StreamController<ChatMessageItem>(
      onCancel: () => cancelCount++,
    );
    controllers.add(controller);
    return controller.stream;
  }
}
