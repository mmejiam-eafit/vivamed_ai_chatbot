import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';

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
  });

  final PreferredSizeWidget appBar;
  final HubActionCard uploadCard;
  final HubActionCard viewStudiesCard;
  final HubActionCard chatCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth.layoutTier == AppLayoutTier.compact;
          return Center(
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
                    : Row(
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
          );
        },
      ),
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
