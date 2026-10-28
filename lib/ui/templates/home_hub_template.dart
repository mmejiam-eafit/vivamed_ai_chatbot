import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';

/// The Home Hub's three primary choices — stacked at compact widths, a
/// single row at medium and up. Exactly 3 fixed cards never need a
/// genuinely different treatment across medium/expanded/ultrawide, unlike
/// `CaseListTemplate`'s dynamic list, so this only branches on compact vs.
/// everything else.
class HomeHubTemplate extends StatelessWidget {
  const HomeHubTemplate({
    super.key,
    required this.appBar,
    required this.uploadCard,
    required this.viewStudiesCard,
    required this.chatCard,
    this.primaryNavDrawer,
    this.menuRail,
  });

  final PreferredSizeWidget appBar;
  final HubActionCard uploadCard;
  final HubActionCard viewStudiesCard;
  final HubActionCard chatCard;

  /// Primary app navigation (Home/Chat/Studies/Review/Settings) at expanded/
  /// ultrawide, replacing the app bar's gear-icon Settings shortcut there --
  /// see DT §9.5 desktop/web revisit. Compact/medium are unchanged: still
  /// just the app bar and its gear icon, no bottom nav bar of its own here.
  final Widget? primaryNavDrawer;

  /// Narrow persistent menu trigger at expanded/ultrawide -- like Case
  /// List/Settings, Home Hub has no conversation-history drawer to
  /// repurpose, so a dedicated MenuRail carries the trigger instead.
  final Widget? menuRail;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth.layoutTier == AppLayoutTier.compact;
        // Shared no-chrome boundary with every other nav-shell template --
        // matches Chat/Study Review's three-pane fit requirement rather than
        // AppLayoutTier.expanded, so the app bar disappears at the same
        // width everywhere (DT §9.5).
        final isWide = constraints.maxWidth >= AppLayout.threePaneMinWidth;
        final content = Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        uploadCard,
                        const SizedBox(height: AppSpacing.lg),
                        viewStudiesCard,
                        const SizedBox(height: AppSpacing.lg),
                        chatCard,
                      ],
                    )
                  // IntrinsicHeight + stretch: the cards are one row, so they
                  // share the tallest one's height instead of each sitting at
                  // its own, centered (descriptions wrap differently at 200%
                  // text, DT §3.7). stretch alone would fail here -- the scroll
                  // view above gives the row an unbounded height.
                  : IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: uploadCard),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: viewStudiesCard),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: chatCard),
                        ],
                      ),
                    ),
            ),
          ),
        );
        return Scaffold(
          backgroundColor: context.colors.surfacePage,
          appBar: isWide ? null : appBar,
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
}

// ── Previews ──────────────────────────────────────────────────────────────────

HubActionCard _previewUploadCard() => HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
    );

HubActionCard _previewViewStudiesCard() => HubActionCard(
      icon: Icons.folder_outlined,
      title: 'View studies',
      description: 'Browse existing studies',
      onTap: () {},
    );

HubActionCard _previewChatCard() => HubActionCard(
      icon: Icons.chat_bubble_outline,
      title: 'Chat',
      description: 'Ask about any case',
      onTap: () {},
    );

@Preview(name: 'compact', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewHomeHubTemplateCompact() => HomeHubTemplate(
      appBar: AppBar(title: const Text('Home')),
      uploadCard: _previewUploadCard(),
      viewStudiesCard: _previewViewStudiesCard(),
      chatCard: _previewChatCard(),
    );

@Preview(name: 'wide', size: Size(900, 600), wrapper: previewWrapperFull)
Widget previewHomeHubTemplateWide() => HomeHubTemplate(
      appBar: AppBar(title: const Text('Home')),
      uploadCard: _previewUploadCard(),
      viewStudiesCard: _previewViewStudiesCard(),
      chatCard: _previewChatCard(),
    );

@Preview(
    name: 'expanded — no app bar, menu rail',
    size: Size(1120, 700),
    wrapper: previewWrapperFull)
Widget previewHomeHubTemplateExpanded() => HomeHubTemplate(
      appBar: AppBar(title: const Text('Home')),
      uploadCard: _previewUploadCard(),
      viewStudiesCard: _previewViewStudiesCard(),
      chatCard: _previewChatCard(),
      menuRail: MenuRail(onMenuTap: () {}),
    );
