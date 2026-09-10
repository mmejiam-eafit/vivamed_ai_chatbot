import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_tab_bar.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class StudyReviewTemplate extends StatelessWidget {
  const StudyReviewTemplate({
    super.key,
    required this.appBar,
    required this.imageViewer,
    required this.findingsPanel,
    required this.chatPanel,
    this.statusBar,
    this.drawer,
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

  /// ConversationDrawer organism.
  /// Wide: rendered as a persistent sidebar inside the Row.
  /// Narrow: passed to Scaffold.drawer as a slide-over.
  final Widget? drawer;

  /// Grounds the image slot in the diagnostic canvas rather than the page
  /// surface. Mode-exempt: the surround of pixel data must not move with a
  /// user preference (DL §3.7, D-004). The Scaffold around it stays themed —
  /// that part is chrome, not evidence.
  static Widget _canvas(Widget imageViewer) => ColoredBox(
        color: DiagnosticImageTokens.canvasGround,
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

  Widget _buildThreeZone(AppColorsData colors, {required bool isUltrawide}) {
    // Ultrawide: viewer and findings sit side by side, and the viewer absorbs
    // the extra width rather than the pair simply growing taller stacked.
    final primaryContent = isUltrawide
        ? Row(
            children: [
              Expanded(flex: 3, child: _canvas(imageViewer)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 2, child: findingsPanel),
            ],
          )
        : Column(
            children: [
              Expanded(flex: 3, child: _canvas(imageViewer)),
              const SizedBox(height: AppSpacing.lg),
              Expanded(flex: 2, child: findingsPanel),
            ],
          );
    return Scaffold(
      backgroundColor: colors.surfacePage,
      appBar: appBar,
      body: Row(
        children: [
          if (drawer != null)
            SizedBox(width: NavigationTokens.sideNavWidth, child: drawer),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                if (statusBar != null) statusBar!,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: primaryContent,
                  ),
                ),
              ],
            ),
          ),
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
        children: [
          if (statusBar != null) statusBar!,
          Expanded(
            child: Row(
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
          if (statusBar != null) statusBar!,
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

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _placeholder(String label, Color color) => Container(
      color: color,
      child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white))),
    );

@Preview(
    name: 'wide — with drawer',
    size: Size(1024, 768),
    wrapper: previewWrapperFull)
Widget previewStudyReviewWide() => StudyReviewTemplate(
      appBar: AppBar(title: const Text('Study Review')),
      imageViewer: _placeholder('Image Viewer', Colors.blueGrey.shade700),
      findingsPanel: _placeholder('Findings Panel', Colors.teal.shade700),
      chatPanel: _placeholder('Chat Panel', Colors.indigo.shade700),
      statusBar: Container(
        height: 36,
        color: Colors.amber.shade100,
        child: const Center(child: Text('Status bar')),
      ),
      drawer: _placeholder('Drawer', Colors.blueGrey.shade900),
    );

@Preview(
    name: 'narrow — tabs', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewStudyReviewNarrow() => StudyReviewTemplate(
      appBar: AppBar(title: const Text('Study Review')),
      imageViewer: _placeholder('Image Viewer', Colors.blueGrey.shade700),
      findingsPanel: _placeholder('Findings Panel', Colors.teal.shade700),
      chatPanel: _placeholder('Chat Panel', Colors.indigo.shade700),
    );
