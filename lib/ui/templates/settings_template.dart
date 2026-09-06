import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';

class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({
    super.key,
    required this.appBar,
    required this.sections,
  });

  final PreferredSizeWidget appBar;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: appBar,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xxl),
        itemBuilder: (_, i) => sections[i],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _previewSection(String title, List<Widget> rows) => Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderCard,
        border: Border.all(color: AppColors.border),
        boxShadow: AppElevation.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(title, style: AppTypography.headingSm, color: AppColors.textPrimary),
          const SizedBox(height: AppSpacing.md),
          ...rows,
        ],
      ),
    );

@Preview(name: 'settings', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewSettingsTemplate() => SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: [
        _previewSection('Account', const [
          MetadataField(label: 'Name', value: 'Dr. A. Ramírez'),
          MetadataField(label: 'Role', value: 'Radiologist'),
          MetadataField(label: 'Email', value: 'aramirez@hospital.org'),
        ]),
        _previewSection('Display', const [
          MetadataField(label: 'Theme', value: 'System'),
          MetadataField(label: 'Language', value: 'English'),
        ]),
        _previewSection('About', const [
          MetadataField(label: 'Version', value: '1.0.0'),
          MetadataField(label: 'Build', value: '2026.05.26'),
        ]),
      ],
    );
