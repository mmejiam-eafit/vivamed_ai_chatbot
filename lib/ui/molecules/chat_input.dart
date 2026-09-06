import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onAttach,
    this.isLoading = false,
    this.hintText = 'Ask about the study…',
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback? onAttach;
  final bool isLoading;
  final String hintText;
  /// Number of lines the input can grow to. Set to a value > 1 on web/desktop
  /// to allow multi-line messages before sending.
  final int maxLines;

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
              maxLines: maxLines,
              textInputAction:
                  maxLines > 1 ? TextInputAction.newline : TextInputAction.send,
              onSubmitted: maxLines > 1 ? null : (_) => onSubmit(),
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
