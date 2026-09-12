import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/chat_bubble.dart';
import 'package:radiologist_helper/ui/molecules/typing_indicator.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    this.isTyping = false,
  });

  final List<ChatMessageItem> messages;
  final bool isTyping;

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
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (widget.isTyping && index == widget.messages.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: TypingIndicator(),
          );
        }
        final msg = widget.messages[index];
        return ChatBubble(
          message: msg.message,
          isUser: msg.isUser,
          avatarImageUrl: msg.avatarImageUrl,
          avatarInitials: msg.avatarInitials,
          timestamp: msg.timestamp,
        );
      },
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _sampleMessages = [
  ChatMessageItem(
    message: 'Can you identify the main finding?',
    isUser: true,
    timestamp: '09:14',
  ),
  ChatMessageItem(
    message: 'There is right lower lobe consolidation consistent with pneumonia.',
    isUser: false,
  ),
  ChatMessageItem(
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

@Preview(name: 'empty', size: Size(390, 120), wrapper: previewWrapperFull)
Widget previewChatMessageListEmpty() => const ChatMessageList(messages: []);
