import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

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
    final effectiveColor = color ?? context.colors.borderSubdued;
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
