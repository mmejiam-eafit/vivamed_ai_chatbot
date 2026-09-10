import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
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
  });

  final PreferredSizeWidget appBar;
  final Widget chatPanel;
  final Widget? findingsPanel;
  final Widget? statusBar;
  final Widget? drawer;

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

  Widget _chatColumn() => Column(
        children: [
          if (statusBar != null) statusBar!,
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
      appBar: appBar,
      body: Row(
        children: [
          if (drawer != null)
            SizedBox(width: NavigationTokens.sideNavWidth, child: drawer),
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
      body: Column(
        children: [
          if (statusBar != null) statusBar!,
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
      endDrawer: findingsPanel == null
          ? null
          : SizedBox(width: AppLayout.panelMaxWidth, child: findingsPanel!),
      // Builder gives Scaffold.of a context below this Scaffold, not the one
      // building it -- required for openDrawer()/openEndDrawer() to find it.
      body: Builder(
        builder: (context) => Row(
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

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _placeholder(String label, Color color) => ColoredBox(
      color: color,
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );

@Preview(name: 'wide', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewChatTemplateWide() => ChatTemplate(
      appBar: AppBar(title: const Text('Chat')),
      chatPanel: _placeholder('Chat Panel', Colors.indigo.shade700),
      findingsPanel: _placeholder('Findings Panel', Colors.teal.shade700),
      statusBar: _placeholder('Status Bar', Colors.blueGrey.shade900),
      drawer: _placeholder('Drawer', Colors.blueGrey.shade700),
    );

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewChatTemplateNarrow() => ChatTemplate(
      appBar: AppBar(title: const Text('Chat')),
      chatPanel: _placeholder('Chat Panel', Colors.indigo.shade700),
      findingsPanel: _placeholder('Findings Panel', Colors.teal.shade700),
    );
