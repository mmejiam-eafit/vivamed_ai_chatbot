import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onAttach,
    this.isLoading = false,
    this.hintText = 'Ask about the study…',
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onAttach;
  final bool isLoading;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ChatTokens.inputBackground,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (onAttach != null) ...[
            AppButton(
              icon: Icons.attach_file,
              variant: AppButtonVariant.iconOnly,
              onPressed: onAttach,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Expanded(
            child: AppTextField(
              controller: controller,
              hintText: hintText,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppButton(
            icon: Icons.send,
            variant: AppButtonVariant.iconOnly,
            onPressed: onSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'default', size: Size(400, 64), wrapper: previewWrapper)
Widget previewChatInputDefault() =>
    ChatInput(controller: TextEditingController(), onSubmit: () {});

@Preview(name: 'with attach button', size: Size(400, 64), wrapper: previewWrapper)
Widget previewChatInputAttach() => ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      onAttach: () {},
    );

@Preview(name: 'loading', size: Size(400, 64), wrapper: previewWrapper)
Widget previewChatInputLoading() => ChatInput(
      controller: TextEditingController(),
      onSubmit: () {},
      isLoading: true,
    );
