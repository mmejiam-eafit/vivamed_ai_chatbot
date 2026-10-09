import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.avatarImageUrl,
    this.avatarInitials,
    this.timestamp,
    this.caseReferences,
    this.onCaseReferenceTap,
  });

  final String message;
  final bool isUser;
  final String? avatarImageUrl;
  final String? avatarInitials;
  final String? timestamp;
  final List<CaseReference>? caseReferences;
  final ValueChanged<String>? onCaseReferenceTap;

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
              if (caseReferences != null && caseReferences!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final ref in caseReferences!)
                        _CaseReferenceChip(
                          title: ref.title,
                          onTap: () => onCaseReferenceTap?.call(ref.caseId),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A small tappable reference to a case, shown below a reply that names one
/// ("I found 2 similar cases: ..."). Not a separate molecule: it had exactly
/// one caller (this file), so per AGENTS.md's simplicity rule ("a second
/// variant earns its place when a second real call site exists") its
/// composition lives here instead of importing another molecule, which the
/// atomic-design layer rules forbid outright.
/// Not `AppChip`: its `onSelected`/`onDeleted` API is a filter/removable-tag
/// semantic that doesn't fit "tap to navigate."
class _CaseReferenceChip extends StatelessWidget {
  const _CaseReferenceChip({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.button + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderButton,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceAccent,
            borderRadius: AppRadius.borderButton,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                Icons.folder_outlined,
                size: 16.0,
                role: AppIconRole.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: AppText(
                  title,
                  style: AppTypography.labelMd,
                  color: colors.textOnAccent,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
