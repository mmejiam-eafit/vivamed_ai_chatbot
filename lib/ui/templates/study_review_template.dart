import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppLayout.templateSplitWidth;
        return isWide ? _buildWide() : _buildNarrow();
      },
    );
  }

  Widget _buildWide() {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
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
                    child: Column(
                      children: [
                        Expanded(flex: 3, child: imageViewer),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(flex: 2, child: findingsPanel),
                      ],
                    ),
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

  Widget _buildNarrow() {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
      appBar: appBar,
      drawer: drawer,
      body: Column(
        children: [
          if (statusBar != null) statusBar!,
          AspectRatio(aspectRatio: 4 / 3, child: imageViewer),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    indicatorColor: AppColors.interactivePrimary,
                    labelColor: AppColors.interactivePrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      Tab(text: 'Findings'),
                      Tab(text: 'Chat'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [findingsPanel, chatPanel],
                    ),
                  ),
                ],
              ),
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
