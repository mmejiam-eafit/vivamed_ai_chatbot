import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/chat_bubble.dart';
import 'package:radiologist_helper/ui/molecules/typing_indicator.dart';

/// The assistant's "typing" bubble -- shown for the explicit `isTyping` flag
/// and for a reply that is streaming but has no text yet.
const _typingIndicator = Align(
  alignment: Alignment.centerLeft,
  child: TypingIndicator(),
);

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.isTyping = false,
    this.onCaseReferenceTap,
  });

  final List<ChatMessageItem> messages;
  final bool isTyping;
  final ValueChanged<String>? onCaseReferenceTap;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isTyping != oldWidget.isTyping) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else if (_lastMessageChanged(oldWidget) && _isPinnedToBottom()) {
      // Streaming text grows the last bubble without changing the count.
      // Checked here, before the new layout, so "pinned" means pinned to the
      // content the user was actually looking at.
      SchedulerBinding.instance.addPostFrameCallback((_) => _followToBottom());
    }
  }

  bool _lastMessageChanged(ChatMessageList oldWidget) {
    if (widget.messages.isEmpty || oldWidget.messages.isEmpty) return false;
    final now = widget.messages.last;
    final before = oldWidget.messages.last;
    return now.message != before.message || now.status != before.status;
  }

  /// A reader who scrolled up to look at something earlier is not yanked back
  /// down by every new chunk of text.
  bool _isPinnedToBottom() {
    if (!_scrollController.hasClients) return false;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels <= AppSpacing.xxxl;
  }

  // jumpTo, not animateTo: chunks arrive many times a second, and an animation
  // restarted on each one would lag behind the text instead of following it.
  void _followToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppMotion.transition,
        curve: AppMotion.enter,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.messages.length + (widget.isTyping ? 1 : 0);
    if (itemCount == 0) {
      return const SizedBox.expand();
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (widget.isTyping && index == widget.messages.length) {
          return _typingIndicator;
        }
        final msg = widget.messages[index];
        if (msg.status == ChatMessageStatus.streaming && msg.message.isEmpty) {
          return _typingIndicator;
        }
        return ChatBubble(
          message: msg.message,
          isUser: msg.isUser,
          status: msg.status,
          avatarImageUrl: msg.avatarImageUrl,
          avatarInitials: msg.avatarInitials,
          timestamp: msg.timestamp,
          caseReferences: msg.caseReferences,
          onCaseReferenceTap: widget.onCaseReferenceTap,
        );
      },
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _sampleMessages = [
  ChatMessageItem(
    id: 'preview-1',
    message: 'Can you identify the main finding?',
    isUser: true,
    timestamp: '09:14',
  ),
  ChatMessageItem(
    id: 'preview-2',
    message: 'There is right lower lobe consolidation consistent with pneumonia.',
    isUser: false,
  ),
  ChatMessageItem(
    id: 'preview-3',
    message: 'Is there any pleural effusion?',
    isUser: true,
    timestamp: '09:15',
  ),
];

@Preview(name: 'conversation', size: Size(390, 400), wrapper: previewWrapperFull)
Widget previewChatMessageListConversation() =>
    const ChatMessageList(messages: _sampleMessages);

@Preview(name: 'with typing indicator', size: Size(390, 440), wrapper: previewWrapperFull)
Widget previewChatMessageListTyping() =>
    const ChatMessageList(messages: _sampleMessages, isTyping: true);

@Preview(name: 'reply streaming', size: Size(390, 440), wrapper: previewWrapperFull)
Widget previewChatMessageListStreaming() => const ChatMessageList(
      messages: [
        ..._sampleMessages,
        ChatMessageItem(
          id: 'preview-4',
          message: 'No pleural effusion is seen, though the',
          isUser: false,
          status: ChatMessageStatus.streaming,
        ),
      ],
    );

@Preview(name: 'reply failed', size: Size(390, 440), wrapper: previewWrapperFull)
Widget previewChatMessageListFailed() => const ChatMessageList(
      messages: [
        ..._sampleMessages,
        ChatMessageItem(
          id: 'preview-4',
          message: 'No pleural effusion is seen, though the',
          isUser: false,
          status: ChatMessageStatus.failed,
        ),
      ],
    );

@Preview(name: 'empty', size: Size(390, 120), wrapper: previewWrapperFull)
Widget previewChatMessageListEmpty() => const ChatMessageList(messages: []);
