import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

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

  /// Interim proportion of the available height given to the findings
  /// bottom sheet at narrow widths. DT §9.5 specifies this slot as a
  /// draggable sheet (gap 17); until that's built, this keeps the sheet's
  /// height responsive to the screen instead of a fixed pixel value.
  static const double _narrowFindingsSheetHeightFraction = 0.4;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nav, chat, and findings side by side only once all three actually
        // fit — not at a flat width, which is how nav (240) + panel (360)
        // used to leave a chat column as narrow as 168px (§9.1).
        final fitsThreePanes =
            constraints.maxWidth >= AppLayout.threePaneMinWidth;
        return fitsThreePanes
            ? _buildWide()
            : _buildNarrow(constraints.maxHeight);
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
            child: Column(
              children: [
                if (statusBar != null) statusBar!,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: chatPanel,
                  ),
                ),
              ],
            ),
          ),
          if (findingsPanel != null)
            SizedBox(width: AppLayout.panelMaxWidth, child: findingsPanel!),
        ],
      ),
    );
  }

  Widget _buildNarrow(double availableHeight) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
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
          : ColoredBox(
              color: AppColors.surface,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      availableHeight * _narrowFindingsSheetHeightFraction,
                ),
                child: findingsPanel!,
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
