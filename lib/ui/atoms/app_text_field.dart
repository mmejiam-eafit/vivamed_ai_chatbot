import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// Styling is handled by buildAppTheme()'s InputDecorationTheme.
// This atom owns only structure and behavior — no manual decoration tokens needed.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return _FocusRing(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppInteraction.minTouchTarget,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          enabled: enabled,
          mouseCursor: enabled
              ? AppInteraction.mouseText
              : AppInteraction.mouseForbidden,
          // obscureText requires maxLines == 1
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}

/// Offset focus ring, mirroring AppButton's — reads against the page rather
/// than relying solely on the shared theme's on-edge border color (DL §8.4).
class _FocusRing extends StatelessWidget {
  const _FocusRing({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            padding: const EdgeInsets.all(AppInteraction.focusRingOffset),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFocus
                    ? context.colors.borderFocused
                    : Colors.transparent,
                width: AppInteraction.focusRingWidth,
              ),
              borderRadius: AppRadius.borderInput,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
