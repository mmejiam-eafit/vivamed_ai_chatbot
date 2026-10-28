import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/atoms/app_tab_bar.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class StudyReviewTemplate extends StatelessWidget {
  const StudyReviewTemplate({
    super.key,
    required this.appBar,
    required this.imageViewer,
    required this.findingsPanel,
    required this.chatPanel,
    this.statusBar,
    this.drawer,
    this.drawerWide,
    this.primaryNavDrawer,
  });

  final PreferredSizeWidget appBar;

  /// DICOM image viewer, or a HeatmapViewerTemplate content widget.
  final Widget imageViewer;

  /// FindingsPanel organism for the current study.
  final Widget findingsPanel;

  /// ChatPanel organism for the AI conversation.
  final Widget chatPanel;

  /// Optional full-width StatusBar organism shown above the main content.
  final Widget? statusBar;

  /// ConversationDrawer organism, compact/medium only.
  /// Narrow: passed to Scaffold.drawer as a slide-over.
  /// Unused at expanded/ultrawide -- see [drawerWide].
  final Widget? drawer;

  /// ConversationDrawer's expanded/ultrawide variant -- same data as
  /// [drawer], but its bottom row opens the primary nav menu instead of
  /// Settings directly (there's no app bar at this tier to host a hamburger
  /// in anymore). Rendered as a persistent sidebar inside the three-zone Row.
  final Widget? drawerWide;

  /// Primary app navigation (Home/Chat/Studies/Review/Settings) at expanded/
  /// ultrawide -- see DT §9.5 desktop/web revisit.
  final Widget? primaryNavDrawer;

  /// Grounds the image slot in the diagnostic canvas rather than the page
  /// surface. Mode-exempt: the surround of pixel data must not move with a
  /// user preference (DL §3.7, D-004). The Scaffold around it stays themed —
  /// that part is chrome, not evidence.
  static Widget _canvas(Widget imageViewer) => ColoredBox(
        color: diagnosticCanvasGround,
        child: imageViewer,
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Three named zones (nav, viewer+findings, chat) only once all three
        // actually fit — below that, chat lives inside the tab strip instead
        // of losing its own column to an unfittable width (§9.1).
        if (width >= AppLayout.threePaneMinWidth) {
          return _buildThreeZone(
            colors,
            isUltrawide: width >= AppLayout.ultrawideMinWidth,
          );
        }
        // Viewer and tabs side by side once there's room for both without
        // either going unreadably narrow, even if that's not yet room for
        // nav and chat as their own zones too.
        if (width >= AppLayout.twoPaneMinWidth) {
          return _buildViewerAndTabs(colors);
        }
        return _buildNarrow(colors);
      },
    );
  }

  Widget _tabs() {
    return AppTabBar(
      tabs: const ['Findings', 'Chat'],
      tabViews: [findingsPanel, chatPanel],
    );
  }

  // Every Column/Row below that holds a slot stretches its cross axis. The
  // default (center) hands each child a *loose* constraint there, so a slot
  // only filled its cell if whatever was passed in happened to fill it too --
  // a content-less or intrinsically-sized widget collapsed to zero or to its
  // own size. A template's slot should fill its cell regardless.
  Widget _buildThreeZone(AppColorsData colors, {required bool isUltrawide}) {
    // Ultrawide: viewer and findings sit side by side, and the viewer absorbs
    // the extra width rather than the pair simply growing taller stacked.
    final primaryContent = isUltrawide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _canvas(imageViewer)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: findingsPanel),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _canvas(imageViewer)),
              const SizedBox(height: AppSpacing.lg),
              Expanded(flex: 2, child: findingsPanel),
            ],
          );
    return Scaffold(
      backgroundColor: colors.surfacePage,
      // No app bar at this tier -- the menu trigger lives at the bottom of
      // drawerWide instead.
      drawer: primaryNavDrawer,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?drawerWide,
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ?statusBar,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: primaryContent,
                  ),
                ),
              ],
            ),
          ),
          const AppDivider(axis: Axis.vertical),
          SizedBox(width: AppLayout.panelMaxWidth, child: chatPanel),
        ],
      ),
    );
  }

  /// Between `twoPaneMinWidth` and `threePaneMinWidth`: room for the viewer
  /// and the findings/chat tabs side by side, but not yet for nav and chat as
  /// their own separate zones too — so the drawer stays an overlay rather
  /// than sitting inline half-finished.
  Widget _buildViewerAndTabs(AppColorsData colors) {
    return Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: appBar,
      drawer: drawer,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?statusBar,
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _canvas(imageViewer),
                  ),
                ),
                Expanded(flex: 2, child: _tabs()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Caps the narrow layout's image slot so a 4:3 `AspectRatio` cannot demand
  /// `width × 0.75` regardless of the height actually available — which
  /// overflowed in exactly this way once a short, wide window reached this
  /// branch (design_tokens.md §12 gap 15).
  static const double _narrowImageHeightFraction = 0.45;

  Widget _buildNarrow(AppColorsData colors) {
    return Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: appBar,
      drawer: drawer,
      body: Column(
        children: [
          ?statusBar,
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight =
                    constraints.maxHeight * _narrowImageHeightFraction;
                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: imageHeight),
                      child:
                          AspectRatio(aspectRatio: 4 / 3, child: _canvas(imageViewer)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(child: _tabs()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
