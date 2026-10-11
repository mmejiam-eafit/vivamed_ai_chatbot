import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/conversation.dart';
// Cyclic with providers.dart by design: that file builds `messagesProvider`
// from this class, and this class reads `chatServiceProvider` from it, but only
// inside methods -- nothing is touched at import time.
import 'package:radiologist_helper/services/providers.dart';

/// One conversation's messages: the fetched history, plus whatever is in
/// flight on top of it.
///
/// An `AsyncNotifier` rather than a plain `StreamProvider` because it has to
/// do two things a stream can't -- start from a fetched list, and take a
/// `send` command that appends to it. Its state keeps the type pages already
/// read (`AsyncValue<List<ChatMessageItem>>`), so they `.when(...)` on it
/// exactly as they did the `FutureProvider` it replaces.
///
/// The family argument arrives through the constructor (Riverpod 3 has no
/// `FamilyAsyncNotifier`); `messagesProvider` passes it by tear-off.
class ChatThreadNotifier extends AsyncNotifier<List<ChatMessageItem>> {
  ChatThreadNotifier(this.arg);

  /// The conversation id this notifier instance is for.
  final String arg;

  StreamSubscription<ChatMessageItem>? _subscription;

  @override
  Future<List<ChatMessageItem>> build() {
    // Runs on a rebuild too, so a stale stream can never write into the fresh
    // state.
    ref.onDispose(() => _subscription?.cancel());
    return ref.watch(chatServiceProvider).getMessages(arg);
  }

  /// Sends [text] and streams the reply into the list. Returns whether it was
  /// accepted, synchronously, so a page can clear its input only if so.
  ///
  /// Refused: empty text, history that hasn't loaded yet, and any send while a
  /// reply is still streaming. The last one needs guarding here, not just by
  /// the send button's loading state, because the keyboard's submit key reaches
  /// the page without going through that button.
  bool send(String text) {
    final history = state.value;
    if (text.isEmpty || history == null || _isStreaming(history)) return false;

    final stamp = DateTime.now().microsecondsSinceEpoch;
    final userMessage = ChatMessageItem(
      id: 'user-$stamp',
      message: text,
      isUser: true,
    );
    // Swapped for the id the stream announces once its first snapshot arrives.
    var assistantId = 'assistant-$stamp';
    state = AsyncData([
      ...history,
      userMessage,
      ChatMessageItem(
        id: assistantId,
        message: '',
        isUser: false,
        status: ChatMessageStatus.streaming,
      ),
    ]);

    _subscription = ref
        .read(chatServiceProvider)
        .streamReply(arg, [...history, userMessage])
        .listen(
      (snapshot) {
        _replace(assistantId, (_) => snapshot);
        assistantId = snapshot.id;
      },
      // Whatever text arrived stays; only the status changes.
      onError: (Object error) => _replace(
        assistantId,
        (m) => m.copyWith(status: ChatMessageStatus.failed),
      ),
      // A stream that closes without ever saying `complete` would otherwise
      // leave the reply streaming forever.
      onDone: () => _replace(
        assistantId,
        (m) => m.status == ChatMessageStatus.streaming
            ? m.copyWith(status: ChatMessageStatus.failed)
            : m,
      ),
    );
    return true;
  }

  static bool _isStreaming(List<ChatMessageItem> messages) =>
      messages.any((m) => m.status == ChatMessageStatus.streaming);

  void _replace(String id, ChatMessageItem Function(ChatMessageItem) change) {
    final messages = state.value;
    if (messages == null) return;
    state = AsyncData([
      for (final m in messages) m.id == id ? change(m) : m,
    ]);
  }
}
