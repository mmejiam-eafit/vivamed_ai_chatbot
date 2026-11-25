import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/section_card.dart';
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
    this.navBar,
    this.primaryNavDrawer,
    this.menuRail,
  });

  final PreferredSizeWidget appBar;
  final List<SettingsSection> sections;
  final Widget? navBar;

  /// Primary app navigation (Home/Chat/Studies/Review/Settings) at expanded/
  /// ultrawide, replacing navBar there -- see DT §9.5 desktop/web revisit.
  final Widget? primaryNavDrawer;

  /// Narrow persistent menu trigger at expanded/ultrawide -- this template
  /// has no conversation-history drawer to repurpose (unlike Chat/Study
  /// Review), so a dedicated MenuRail carries the trigger instead. No app
  /// bar at this tier to host a hamburger in anymore.
  final Widget? menuRail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tier = constraints.maxWidth.layoutTier;
        // Shared no-chrome boundary with every other nav-shell template --
        // matches Chat/Study Review's three-pane fit requirement rather than
        // AppLayoutTier.expanded, so the app bar disappears at the same
        // width everywhere (DT §9.5).
        final isWide = constraints.maxWidth >= AppLayout.threePaneMinWidth;
        return Scaffold(
          backgroundColor: context.colors.surfacePage,
          appBar: isWide ? null : appBar,
          bottomNavigationBar: isWide ? null : navBar,
          drawer: isWide ? primaryNavDrawer : null,
          body: isWide
              ? _buildWide()
              : _buildSingleColumn(isCompact: tier == AppLayoutTier.compact),
        );
      },
    );
  }

  Widget _sectionList(EdgeInsets padding) => ListView.separated(
        padding: padding,
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xxl),
        itemBuilder: (_, i) =>
            SectionCard(title: sections[i].title, child: sections[i].child),
      );

  Widget _buildSingleColumn({required bool isCompact}) {
    final list = _sectionList(
      const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
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

  // One column beside the menu rail, with no section index: every section
  // fits within about one screen here (DL D-025).
  Widget _buildWide() => Row(
        children: [
          ?menuRail,
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _sectionList(const EdgeInsets.all(AppSpacing.xl)),
              ),
            ),
          ),
        ],
      );
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
      navBar: AppNavBar(
        selectedIndex: 4,
        onDestinationSelected: (_) {},
        pendingReviewCount: 0,
      ),
    );

@Preview(name: 'settings — expanded', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewSettingsTemplateExpanded() => SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: _previewSections(),
    );
