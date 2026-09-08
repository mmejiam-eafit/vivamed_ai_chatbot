import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

enum SeverityLevel { normal, mild, moderate, critical }

class SeverityDot extends StatelessWidget {
  const SeverityDot({
    super.key,
    required this.severity,
    this.size = 8.0,
  });

  final SeverityLevel severity;
  final double size;

  static Color _colorFor(SeverityData data, SeverityLevel level) =>
      switch (level) {
        SeverityLevel.normal => data.normal,
        SeverityLevel.mild => data.mild,
        SeverityLevel.moderate => data.moderate,
        SeverityLevel.critical => data.critical,
      };

  // Distinct silhouettes so severity survives without hue (DL §3.6, D-003).
  static IconData _shapeFor(SeverityLevel level) => switch (level) {
        SeverityLevel.normal => Icons.circle,
        SeverityLevel.mild => Icons.square,
        SeverityLevel.moderate => Icons.change_history,
        SeverityLevel.critical => Icons.diamond,
      };

  @override
  Widget build(BuildContext context) {
    return Icon(
      _shapeFor(severity),
      size: size,
      color: _colorFor(context.severity, severity),
    );
  }
}
