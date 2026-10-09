import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class CaseListTemplate extends StatelessWidget {
  const CaseListTemplate({
    super.key,
    required this.appBar,
    required this.caseSlots,
    required this.worklistTable,
    this.header,
    this.statusBar,
    this.emptyState,
    this.navBar,
    this.primaryNavDrawer,
    this.menuRail,
  });

  final PreferredSizeWidget appBar;

  /// Compact and medium tiers — one `StudyInfoCard` per case.
  final List<Widget> caseSlots;

  /// Expanded and ultrawide tiers — the dense sortable table (DT §9.5).
  /// An opaque slot like every other template slot: this template never sees
  /// the underlying case data, only whatever widget the page builds from it.
  final Widget worklistTable;

  final Widget? header;
  final Widget? statusBar;
  final Widget? emptyState;
  final Widget? navBar;

  /// Primary app navigation (Home/Chat/Studies/Settings) at expanded/
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
        // stretch: a `header`/`statusBar` slot spans the content's width
        // instead of floating centered at its own natural width, or collapsing
        // to nothing when it has no width of its own (DT §9.5).
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?statusBar,
            if (header != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: header,
              ),
            Expanded(child: _buildContent(tier, isWide)),
          ],
        );
        return Scaffold(
          backgroundColor: context.colors.surfacePage,
          appBar: isWide ? null : appBar,
          bottomNavigationBar: isWide ? null : navBar,
          drawer: isWide ? primaryNavDrawer : null,
          body: isWide
              ? Row(
                  children: [
                    ?menuRail,
                    Expanded(child: content),
                  ],
                )
              : content,
        );
      },
    );
  }

  Widget _buildContent(AppLayoutTier tier, bool isWide) {
    if (caseSlots.isEmpty && emptyState != null) {
      return Center(child: emptyState);
    }

    if (isWide) {
      // Capped at worklistMaxWidth at every wide width, not only ultrawide
      // (DT §9.5, D-019). It binds once the content area -- the window minus
      // the 64px menu rail -- exceeds the cap, from about 1504px. Ultrawide-
      // only would let the table shrink from ~1535px to the cap at exactly
      // 1600px as the window grew. Centered horizontally only: a Center would
      // float a short table at the window's vertical middle (DT §9.5).
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppLayout.worklistMaxWidth),
          child: worklistTable,
        ),
      );
    }

    if (tier == AppLayoutTier.compact) {
      return ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: caseSlots.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, i) => caseSlots[i],
      );
    }

    // Medium, and expanded-but-narrower-than-threePaneMinWidth: two columns
    // via Wrap, not GridView's fixed-aspect-ratio delegate (the only kind
    // Flutter's grid delegates offer) -- a StudyInfoCard with more metadata
    // fields, or 200%-scaled text, needs its row to grow with it rather than
    // clip inside a fixed-height cell (gap 20).
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columnWidth =
                  (constraints.maxWidth - AppSpacing.lg) / 2;
              return Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: [
                  for (final slot in caseSlots)
                    SizedBox(width: columnWidth, child: slot),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
