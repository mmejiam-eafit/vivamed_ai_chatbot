import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

enum SeverityLevel { normal, mild, moderate, critical }

class SeverityDot extends StatelessWidget {
  const SeverityDot({
    super.key,
    required this.severity,
    this.size = 8.0,
  });

  final SeverityLevel severity;
  final double size;

  Color _colorFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => SeverityTokens.normal,
        SeverityLevel.mild => SeverityTokens.mild,
        SeverityLevel.moderate => SeverityTokens.moderate,
        SeverityLevel.critical => SeverityTokens.critical,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorFor(severity),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'all severities', wrapper: previewWrapper)
Widget previewSeverityDots() => const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SeverityDot(severity: SeverityLevel.normal),
        SizedBox(width: AppSpacing.sm),
        SeverityDot(severity: SeverityLevel.mild),
        SizedBox(width: AppSpacing.sm),
        SeverityDot(severity: SeverityLevel.moderate),
        SizedBox(width: AppSpacing.sm),
        SeverityDot(severity: SeverityLevel.critical),
      ],
    );

@Preview(name: 'large — critical', wrapper: previewWrapper)
Widget previewSeverityDotLarge() =>
    const SeverityDot(severity: SeverityLevel.critical, size: 16.0);
