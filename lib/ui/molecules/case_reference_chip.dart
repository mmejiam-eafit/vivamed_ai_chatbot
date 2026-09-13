import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// A small tappable reference to a case, e.g. below a chat reply that names
/// one ("I found 2 similar cases: ..."). Not `AppChip`: its `onSelected`/
/// `onDeleted` API is a filter/removable-tag semantic that doesn't fit "tap
/// to navigate," so this is its own molecule instead.
class CaseReferenceChip extends StatelessWidget {
  const CaseReferenceChip({
    super.key,
    required this.title,
    required this.onTap,
    this.focusNode,
  });

  final String title;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.button + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: onTap,
        focusNode: focusNode,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderButton,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceAccent,
            borderRadius: AppRadius.borderButton,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                Icons.folder_outlined,
                size: 16.0,
                role: AppIconRole.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: AppText(
                  title,
                  style: AppTypography.labelMd,
                  color: colors.textOnAccent,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'case reference chip', size: Size(220, 60), wrapper: previewWrapper)
Widget previewCaseReferenceChip() => CaseReferenceChip(
      title: 'Abdominal CT',
      onTap: () {},
    );
