import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// One of the Home Hub's big primary choices (upload a study, view studies,
/// chat) — icon, title, description, the whole card tappable.
class HubActionCard extends StatelessWidget {
  const HubActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.focusNode,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  static const _iconSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.card + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        focusNode: focusNode,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderCard,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.borderCard,
            boxShadow: AppElevation.card,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(icon, size: _iconSize, role: AppIconRole.accent),
              const SizedBox(height: AppSpacing.md),
              AppText(
                title,
                style: AppTypography.headingSm,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                description,
                style: AppTypography.bodySm,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'upload', size: Size(220, 200), wrapper: previewWrapper)
Widget previewHubActionCardUpload() => HubActionCard(
      icon: Icons.upload_file,
      title: 'Upload a study',
      description: 'Analyze a new DICOM study',
      onTap: () {},
    );

@Preview(name: 'view studies', size: Size(220, 200), wrapper: previewWrapper)
Widget previewHubActionCardStudies() => HubActionCard(
      icon: Icons.folder_outlined,
      title: 'View studies',
      description: 'Browse existing studies',
      onTap: () {},
    );

@Preview(name: 'chat', size: Size(220, 200), wrapper: previewWrapper)
Widget previewHubActionCardChat() => HubActionCard(
      icon: Icons.chat_bubble_outline,
      title: 'Chat',
      description: 'Ask about any case',
      onTap: () {},
    );
