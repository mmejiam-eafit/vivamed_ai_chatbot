import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// The Settings Appearance section's theme picker (DT §10.5). Always exactly
/// three rows, Dark / Light / System in that order (DL D-013) — a generic
/// n-way choice control would be over-building for what's specifically
/// always this fixed choice, and no radio/segmented-control atom exists
/// anywhere in the app to reuse instead.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in _options)
          _ThemeModeRow(
            label: option.label,
            isSelected: selected == option.mode,
            onTap: () => onChanged(option.mode),
          ),
      ],
    );
  }
}

class _ThemeModeRow extends StatelessWidget {
  const _ThemeModeRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                label,
                style: AppTypography.bodyMd,
                color: isSelected ? colors.interactivePrimary : colors.textPrimary,
              ),
            ),
            if (isSelected)
              AppIcon(Icons.check, color: colors.interactivePrimary, size: 20.0),
          ],
        ),
      ),
    );
  }
}
