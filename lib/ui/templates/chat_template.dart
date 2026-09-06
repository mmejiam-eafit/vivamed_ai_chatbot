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

  Widget _buildNarrow() {
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
                constraints:
                    const BoxConstraints(maxHeight: AppLayout.panelMaxWidth),
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
