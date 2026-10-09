import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/chat_bubble.dart';
import 'package:radiologist_helper/ui/molecules/chat_input.dart';

// Takes a pre-built messageList widget to avoid importing the ChatMessageList organism.
class ChatPanel extends StatelessWidget {
  const ChatPanel({
    super.key,
    required this.messageList,
    required this.controller,
    required this.onSubmit,
    this.onAttach,
    this.isLoading = false,
  });

  final Widget messageList;
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onAttach;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Stretch so the messageList slot fills the panel's width whatever it
      // holds (see ChatTemplate for why the default centering is wrong here).
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: messageList),
        Divider(height: 1, thickness: 1, color: context.colors.borderSubdued),
        ChatInput(
          controller: controller,
          onSubmit: onSubmit,
          onAttach: onAttach,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _previewMessageList() => ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        ChatBubble(
          message: 'Is there consolidation in the right lower lobe?',
          isUser: true,
          timestamp: '09:14',
        ),
        SizedBox(height: AppSpacing.sm),
        ChatBubble(
          message: 'Yes, there is a right lower lobe consolidation consistent with pneumonia.',
          isUser: false,
        ),
        SizedBox(height: AppSpacing.sm),
        ChatBubble(
          message: 'Any pleural effusion?',
          isUser: true,
          timestamp: '09:15',
        ),
      ],
    );

@Preview(name: 'chat panel', size: Size(390, 560), wrapper: previewWrapperFull)
Widget previewChatPanel() => ChatPanel(
      messageList: _previewMessageList(),
      controller: TextEditingController(),
      onSubmit: () {},
    );

@Preview(name: 'chat panel — with attach', size: Size(390, 560), wrapper: previewWrapperFull)
Widget previewChatPanelAttach() => ChatPanel(
      messageList: _previewMessageList(),
      controller: TextEditingController(),
      onSubmit: () {},
      onAttach: () {},
    );

@Preview(name: 'chat panel — loading', size: Size(390, 560), wrapper: previewWrapperFull)
Widget previewChatPanelLoading() => ChatPanel(
      messageList: _previewMessageList(),
      controller: TextEditingController(),
      onSubmit: () {},
      isLoading: true,
    );
