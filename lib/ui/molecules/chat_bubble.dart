import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.avatarImageUrl,
    this.avatarInitials,
    this.timestamp,
  });

  final String message;
  final bool isUser;
  final String? avatarImageUrl;
  final String? avatarInitials;
  final String? timestamp;

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.of(context).size.width * ChatTokens.bubbleMaxWidthFraction;
    final hasAvatar = avatarImageUrl != null || avatarInitials != null;

    final bubbleBox = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isUser ? ChatTokens.userBubble : ChatTokens.assistantBubble,
        borderRadius:
            isUser ? ChatTokens.bubbleRadiusUser : ChatTokens.bubbleRadiusAssistant,
        border: isUser
            ? null
            : Border.all(color: ChatTokens.assistantBubbleBorder),
      ),
      child: AppText(
        message,
        style: AppTypography.bodyMd,
        color: isUser ? ChatTokens.userBubbleText : ChatTokens.assistantBubbleText,
      ),
    );

    final avatar = hasAvatar
        ? AppAvatar(
            imageUrl: avatarImageUrl,
            initials: avatarInitials,
            radius: 16.0,
          )
        : null;

    final bubbleRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isUser
          ? [
              bubbleBox,
              if (avatar != null) ...[
                const SizedBox(width: AppSpacing.sm),
                avatar,
              ],
            ]
          : [
              if (avatar != null) ...[
                avatar,
                const SizedBox(width: AppSpacing.sm),
              ],
              bubbleBox,
            ],
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bubbleRow,
          if (timestamp != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              timestamp!,
              style: AppTypography.caption,
              color: ChatTokens.timestamp,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'user bubble', size: Size(360, 80), wrapper: previewWrapper)
Widget previewChatBubbleUser() =>
    const ChatBubble(message: 'Is there any consolidation visible?', isUser: true);

@Preview(name: 'assistant bubble', size: Size(360, 100), wrapper: previewWrapper)
Widget previewChatBubbleAssistant() => const ChatBubble(
      message: 'Yes, there is a right lower lobe consolidation.',
      isUser: false,
    );

@Preview(name: 'user — with timestamp', size: Size(360, 96), wrapper: previewWrapper)
Widget previewChatBubbleTimestamp() => const ChatBubble(
      message: 'Thanks!',
      isUser: true,
      timestamp: '10:42 AM',
    );

@Preview(name: 'assistant — with avatar', size: Size(360, 100), wrapper: previewWrapper)
Widget previewChatBubbleAvatar() => const ChatBubble(
      message: 'Analysis complete.',
      isUser: false,
      avatarInitials: 'AI',
    );
