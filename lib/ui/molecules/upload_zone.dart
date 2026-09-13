import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

enum UploadZoneStatus { idle, uploading, analyzing }

/// The one interactive area of the Upload screen — a tappable zone that
/// carries all three of its pre-terminal states (idle/uploading/analyzing)
/// in one place. Success/failure is a separate `StatusBar`, not this widget.
class UploadZone extends StatelessWidget {
  const UploadZone({
    super.key,
    required this.status,
    required this.onTap,
    this.selectedFileNames,
    this.focusNode,
  });

  final UploadZoneStatus status;
  final VoidCallback onTap;

  /// A study is a DICOM series — usually many files, not one. Shown as a
  /// count, not a file listing: real instance filenames are opaque UIDs,
  /// not something a radiologist can usefully read off a list.
  final List<String>? selectedFileNames;
  final FocusNode? focusNode;

  static const _iconSize = 40.0;

  String get _label => switch (status) {
        UploadZoneStatus.idle => switch (selectedFileNames) {
            null || [] => 'Tap to choose a study (DICOM files)',
            final files =>
              '${files.length} file${files.length == 1 ? '' : 's'} selected',
          },
        UploadZoneStatus.uploading => 'Uploading…',
        UploadZoneStatus.analyzing => 'Analyzing…',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBusy = status != UploadZoneStatus.idle;
    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.card + AppInteraction.focusRingOffset,
      ),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        focusNode: focusNode,
        hoverColor: colors.textPrimary.withValues(
          alpha: AppInteraction.hoverOverlayOpacity,
        ),
        borderRadius: AppRadius.borderCard,
        child: Container(
          decoration: BoxDecoration(
            // A solid border, not dashed -- Flutter has no built-in dashed
            // border without a CustomPainter or a package; this is the
            // simplest choice that adds neither for this pass.
            border: Border.all(color: colors.border),
            borderRadius: AppRadius.borderCard,
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isBusy
                  ? const AppLoadingIndicator()
                  : const AppIcon(
                      Icons.upload_file,
                      size: _iconSize,
                      role: AppIconRole.accent,
                    ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                _label,
                style: AppTypography.bodyMd,
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

@Preview(name: 'idle', size: Size(280, 200), wrapper: previewWrapper)
Widget previewUploadZoneIdle() =>
    UploadZone(status: UploadZoneStatus.idle, onTap: () {});

@Preview(name: 'idle — files selected', size: Size(280, 200), wrapper: previewWrapper)
Widget previewUploadZoneSelected() => UploadZone(
      status: UploadZoneStatus.idle,
      selectedFileNames: const ['1.2.840.001.dcm', '1.2.840.002.dcm', '1.2.840.003.dcm'],
      onTap: () {},
    );

@Preview(name: 'uploading', size: Size(280, 200), wrapper: previewWrapper)
Widget previewUploadZoneUploading() =>
    UploadZone(status: UploadZoneStatus.uploading, onTap: () {});

@Preview(name: 'analyzing', size: Size(280, 200), wrapper: previewWrapper)
Widget previewUploadZoneAnalyzing() =>
    UploadZone(status: UploadZoneStatus.analyzing, onTap: () {});
