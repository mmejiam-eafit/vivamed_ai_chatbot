import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// The Settings Appearance section's theme picker (DT §10.5). Always exactly
/// three rows, Dark / Light / System in that order (DL D-013) — built on
/// Flutter's own `ListTile` (title + trailing + onTap + selected fill) rather
/// than a hand-rolled row, since that's exactly this shape.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  static const _options = [
    (mode: ThemeMode.dark, label: 'Dark'),
    (mode: ThemeMode.light, label: 'Light'),
    (mode: ThemeMode.system, label: 'System'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // This lives inside SectionCard's own decorated (opaque) Container --
    // without a Material ancestor of its own, ListTile's hover/ink effects
    // would paint on SectionCard's background instead and never be seen.
    // `transparency` adds nothing visually, just an ink-drawing surface.
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in _options)
            ListTile(
              title: AppText(
                option.label,
                style: AppTypography.bodyMd,
                color: selected == option.mode
                    ? colors.interactivePrimary
                    : colors.textPrimary,
              ),
              trailing: selected == option.mode
                  ? AppIcon(Icons.check, color: colors.interactivePrimary, size: 20.0)
                  : null,
              hoverColor: colors.textPrimary.withValues(
                alpha: AppInteraction.hoverOverlayOpacity,
              ),
              onTap: () => onChanged(option.mode),
            ),
        ],
      ),
    );
  }
}
