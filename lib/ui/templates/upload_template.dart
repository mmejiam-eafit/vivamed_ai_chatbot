import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/molecules/upload_zone.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';

/// One focused task regardless of viewport width — no tier branching, same
/// centered-column shape `AuthTemplate` already uses for the same reason.
class UploadTemplate extends StatelessWidget {
  const UploadTemplate({
    super.key,
    required this.appBar,
    required this.uploadZone,
    required this.actionButton,
    this.statusBar,
  });

  final PreferredSizeWidget appBar;
  final UploadZone uploadZone;
  final AppButton actionButton;
  final StatusBar? statusBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      body: SafeArea(
        child: Column(
          children: [
            ?statusBar,
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: AppLayout.formMaxWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        uploadZone,
                        const SizedBox(height: AppSpacing.lg),
                        actionButton,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'idle, no selection', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewUploadTemplateIdle() => UploadTemplate(
      appBar: AppBar(title: const Text('Upload a Study')),
      uploadZone: UploadZone(status: UploadZoneStatus.idle, onTap: () {}),
      actionButton: const AppButton(label: 'Upload', onPressed: null),
    );

@Preview(name: 'files selected', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewUploadTemplateSelected() => UploadTemplate(
      appBar: AppBar(title: const Text('Upload a Study')),
      uploadZone: UploadZone(
        status: UploadZoneStatus.idle,
        selectedFileNames: const ['1.dcm', '2.dcm', '3.dcm'],
        onTap: () {},
      ),
      actionButton: AppButton(label: 'Upload', onPressed: () {}),
    );

@Preview(name: 'uploading', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewUploadTemplateUploading() => UploadTemplate(
      appBar: AppBar(title: const Text('Upload a Study')),
      uploadZone: UploadZone(status: UploadZoneStatus.uploading, onTap: () {}),
      actionButton: const AppButton(label: 'Upload', onPressed: null, isLoading: true),
    );

@Preview(name: 'success', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewUploadTemplateSuccess() => UploadTemplate(
      appBar: AppBar(title: const Text('Upload a Study')),
      uploadZone: UploadZone(
        status: UploadZoneStatus.idle,
        selectedFileNames: const ['1.dcm', '2.dcm', '3.dcm'],
        onTap: () {},
      ),
      actionButton: AppButton(label: 'Upload', onPressed: () {}),
      statusBar: StatusBar(
        message: 'Study processed successfully',
        variant: StatusBannerVariant.success,
        actionLabel: 'View Study',
        onAction: () {},
      ),
    );

@Preview(name: 'error', size: Size(390, 600), wrapper: previewWrapperFull)
Widget previewUploadTemplateError() => UploadTemplate(
      appBar: AppBar(title: const Text('Upload a Study')),
      uploadZone: UploadZone(
        status: UploadZoneStatus.idle,
        selectedFileNames: const ['1.dcm', '2.dcm', '3.dcm'],
        onTap: () {},
      ),
      actionButton: AppButton(label: 'Upload', onPressed: () {}),
      statusBar: StatusBar(
        message: 'Upload failed.',
        variant: StatusBannerVariant.error,
        actionLabel: 'Retry',
        onAction: () {},
      ),
    );
