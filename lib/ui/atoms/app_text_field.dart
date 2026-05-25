import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

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
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      // obscureText requires maxLines == 1
      maxLines: obscureText ? 1 : maxLines,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'empty with hint', size: Size(320, 56), wrapper: previewWrapper)
Widget previewAppTextFieldEmpty() =>
    AppTextField(controller: TextEditingController(), hintText: 'Search…');

@Preview(name: 'with prefix icon', size: Size(320, 56), wrapper: previewWrapper)
Widget previewAppTextFieldPrefix() => AppTextField(
      controller: TextEditingController(),
      hintText: 'Search…',
      prefixIcon: const Icon(Icons.search),
    );

@Preview(name: 'disabled', size: Size(320, 56), wrapper: previewWrapper)
Widget previewAppTextFieldDisabled() => AppTextField(
      controller: TextEditingController(text: 'Read-only'),
      enabled: false,
    );

@Preview(name: 'multiline', size: Size(320, 120), wrapper: previewWrapper)
Widget previewAppTextFieldMultiline() =>
    AppTextField(controller: TextEditingController(), hintText: 'Notes…', maxLines: 4);
