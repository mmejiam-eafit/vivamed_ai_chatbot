import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

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
    // The cap is a fraction of this bubble's own box, not the window — a
    // bubble inside a narrow chat pane must not size itself off the whole
    // screen (DT §9.6).
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.min(
          constraints.maxWidth * ChatTokens.bubbleMaxWidthFraction,
          ChatTokens.bubbleMaxAbsoluteWidth,
        );
        final hasAvatar = avatarImageUrl != null || avatarInitials != null;

        final bubbleBox = Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? ChatTokens.userBubble(context)
                : ChatTokens.assistantBubble(context),
            borderRadius: isUser
                ? ChatTokens.bubbleRadiusUser
                : ChatTokens.bubbleRadiusAssistant,
            border: isUser
                ? null
                : Border.all(color: ChatTokens.assistantBubbleBorder(context)),
          ),
          child: AppText(
            message,
            // bodyLg, not bodyMd — DT §3.2 specifies chat messages one step
            // up from the default body size.
            style: AppTypography.bodyLg,
            color: isUser
                ? ChatTokens.userBubbleText(context)
                : ChatTokens.assistantBubbleText(context),
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
                  color: ChatTokens.timestamp(context),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
