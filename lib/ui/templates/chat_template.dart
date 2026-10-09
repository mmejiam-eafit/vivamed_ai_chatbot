import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/collapsed_nav_rail.dart';
import 'package:radiologist_helper/ui/organisms/draggable_findings_sheet.dart';

class ChatTemplate extends StatelessWidget {
  const ChatTemplate({
    super.key,
    required this.appBar,
    required this.chatPanel,
    this.findingsPanel,
    this.statusBar,
    this.drawer,
    this.drawerWide,
    this.navBar,
    this.primaryNavDrawer,
  });

  final PreferredSizeWidget appBar;
  final Widget chatPanel;
  final Widget? findingsPanel;
  final Widget? statusBar;

  /// Conversation history at compact/medium (Scaffold.drawer overlay/rail
  /// trigger) -- unused at expanded/ultrawide, which reads [drawerWide]
  /// instead.
  final Widget? drawer;

  /// Conversation history's expanded/ultrawide variant -- same data as
  /// [drawer], but its bottom row opens the primary nav menu instead of
  /// Settings directly (there's no app bar at this tier to host a hamburger
  /// in anymore). Rendered inline in the wide Row, same as [drawer] was.
  final Widget? drawerWide;

  final Widget? navBar;

  /// Primary app navigation (Home/Chat/Studies/Settings) at expanded/
  /// ultrawide, replacing navBar there -- see DT §9.5 desktop/web revisit.
  final Widget? primaryNavDrawer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nav, chat, and findings side by side only once all three actually
        // fit — not at a flat width, which is how nav (240) + panel (360)
        // used to leave a chat column as narrow as 168px (§9.1).
        final fitsThreePanes =
            constraints.maxWidth >= AppLayout.threePaneMinWidth;
        if (fitsThreePanes) return _buildWide(colors);
        // Below that, compact keeps the drawer + bottom sheet; medium (and
        // whatever's left of expanded once panes don't fit) collapses to a
        // rail instead (§9.5).
        final isCompact =
            constraints.maxWidth.layoutTier == AppLayoutTier.compact;
        return isCompact
            ? _buildNarrow(colors, constraints.maxHeight)
            : _buildRail(colors);
      },
    );
  }

  // Every Column/Row below that holds a slot stretches its cross axis. The
  // default (center) hands each child a *loose* constraint there, so a slot
  // only filled its cell if whatever was passed in happened to fill it too --
  // a content-less or intrinsically-sized widget collapsed to zero or to its
  // own size. A template's slot should fill its cell regardless.
  Widget _chatColumn() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?statusBar,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: chatPanel,
            ),
          ),
        ],
      );

  Widget _buildWide(AppColorsData colors) {
    return Scaffold(
      backgroundColor: colors.surfacePage,
      // No app bar at this tier -- the menu trigger lives at the bottom of
      // drawerWide (or inside the drawer itself) instead.
      drawer: primaryNavDrawer,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?drawerWide,
          Expanded(child: _chatColumn()),
          if (findingsPanel != null)
            SizedBox(width: AppLayout.panelMaxWidth, child: findingsPanel!),
        ],
      ),
    );
  }

  Widget _buildNarrow(AppColorsData colors, double availableHeight) {
    return Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: appBar,
      drawer: drawer,
      bottomNavigationBar: navBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?statusBar,
          Expanded(child: chatPanel),
        ],
      ),
      bottomSheet: findingsPanel == null
          ? null
          : DraggableFindingsSheet(
              availableHeight: availableHeight,
              child: findingsPanel!,
            ),
    );
  }

  // Medium (and whatever's left of expanded once three panes don't fit):
  // conversations collapse to a 64px rail, findings become a trailing
  // slide-over via Scaffold.endDrawer (§9.5).
  Widget _buildRail(AppColorsData colors) {
    return Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: appBar,
      drawer: drawer,
      bottomNavigationBar: navBar,
      endDrawer: findingsPanel == null
          ? null
          : SizedBox(width: AppLayout.panelMaxWidth, child: findingsPanel!),
      // Builder gives Scaffold.of a context below this Scaffold, not the one
      // building it -- required for openDrawer()/openEndDrawer() to find it.
      body: Builder(
        builder: (context) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CollapsedNavRail(
              onMenuTap: () => Scaffold.of(context).openDrawer(),
              onFindingsTap: findingsPanel == null
                  ? null
                  : () => Scaffold.of(context).openEndDrawer(),
            ),
            Expanded(child: _chatColumn()),
          ],
        ),
      ),
    );
  }
}
