import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';
import 'package:radiologist_helper/ui/molecules/section_index_tile.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';

/// One titled block of settings content, rendered in a [SectionCard] —
/// callers supply only the title and the content underneath it.
class SettingsSection {
  const SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;
}

class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({
    super.key,
    required this.appBar,
    required this.sections,
    this.selectedIndex = 0,
    this.onSectionSelected,
    this.navBar,
  });

  final PreferredSizeWidget appBar;
  final List<SettingsSection> sections;

  /// Which section shows in the content pane at expanded and up (DT §9.5).
  /// Ignored below that tier, where every section renders in one column.
  final int selectedIndex;
  final ValueChanged<int>? onSectionSelected;
  final Widget? navBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      bottomNavigationBar: navBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxWidth.layoutTier;
          if (tier == AppLayoutTier.expanded ||
              tier == AppLayoutTier.ultrawide) {
            return _buildTwoColumn(context);
          }
          return _buildSingleColumn(isCompact: tier == AppLayoutTier.compact);
        },
      ),
    );
  }

  Widget _buildSingleColumn({required bool isCompact}) {
    final list = ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xxl),
      itemBuilder: (_, i) =>
          SectionCard(title: sections[i].title, child: sections[i].child),
    );
    if (isCompact) return list;
    // Medium: capped, not full-bleed, like every other single-column page
    // at this tier (DT §9.5).
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: list,
      ),
    );
  }

  // Every section renders together in one continuous scroll -- the index
  // rail highlights and jumps to a section, it no longer hides the other two
  // (issues.md: Settings should keep "a continuous feel", not read as three
  // separate pages). Section titles are literal strings, so a
  // GlobalObjectKey built from one is stable (equal) across rebuilds without
  // any extra state -- unlike a fresh GlobalKey(), which would be a new
  // identity every time this method reruns and would break the very next
  // tap's ensureVisible call.
  Widget _buildTwoColumn(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    final index = selectedIndex.clamp(0, sections.length - 1);
    final sectionKeys = [
      for (final section in sections) GlobalObjectKey(section.title),
    ];
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            itemCount: sections.length,
            itemBuilder: (context, i) => SectionIndexTile(
              title: sections[i].title,
              isSelected: i == index,
              onTap: () {
                onSectionSelected?.call(i);
                Scrollable.ensureVisible(
                  sectionKeys[i].currentContext!,
                  duration: AppMotion.transition,
                  curve: AppMotion.standard,
                );
              },
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: context.colors.borderSubdued,
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.xl),
                itemCount: sections.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.xxl),
                itemBuilder: (context, i) => SectionCard(
                  key: sectionKeys[i],
                  title: sections[i].title,
                  child: sections[i].child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

List<SettingsSection> _previewSections() => const [
      SettingsSection(
        title: 'Account',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetadataField(label: 'Name', value: 'Dr. A. Ramírez'),
            MetadataField(label: 'Role', value: 'Radiologist'),
            MetadataField(label: 'Email', value: 'aramirez@hospital.org'),
          ],
        ),
      ),
      SettingsSection(
        title: 'Display',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetadataField(label: 'Theme', value: 'System'),
            MetadataField(label: 'Language', value: 'English'),
          ],
        ),
      ),
      SettingsSection(
        title: 'About',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetadataField(label: 'Version', value: '1.0.0'),
            MetadataField(label: 'Build', value: '2026.05.26'),
          ],
        ),
      ),
    ];

@Preview(name: 'settings — compact/medium', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewSettingsTemplate() => SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: _previewSections(),
      navBar: AppNavBar(selectedIndex: 3, onDestinationSelected: (_) {}),
    );

@Preview(name: 'settings — expanded', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewSettingsTemplateExpanded() => SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: _previewSections(),
      selectedIndex: 1,
    );
