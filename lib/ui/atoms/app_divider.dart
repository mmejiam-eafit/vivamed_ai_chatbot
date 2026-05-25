import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.indent,
    this.endIndent,
    this.color,
  });

  final Axis axis;
  final double thickness;
  final double? indent;
  final double? endIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.borderSubdued;
    if (axis == Axis.vertical) {
      return VerticalDivider(
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        color: effectiveColor,
      );
    }
    return Divider(
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: effectiveColor,
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'horizontal', size: Size(240, 24), wrapper: previewWrapper)
Widget previewAppDividerHorizontal() => const AppDivider();

@Preview(name: 'horizontal — indented', size: Size(240, 24), wrapper: previewWrapper)
Widget previewAppDividerIndented() =>
    const AppDivider(indent: 16, endIndent: 16);

@Preview(name: 'vertical', size: Size(24, 80), wrapper: previewWrapper)
Widget previewAppDividerVertical() => const AppDivider(axis: Axis.vertical);
