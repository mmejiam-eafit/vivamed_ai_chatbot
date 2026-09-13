import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/molecules/upload_zone.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/upload_template.dart';

Future<List<String>?> _defaultPickFiles() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['dcm'],
  );
  return result?.files.map((f) => f.name).toList();
}

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key, this.pickFiles = _defaultPickFiles});

  /// The real OS file picker by default; overridable in tests, since a real
  /// plugin channel isn't available under `flutter test`.
  final Future<List<String>?> Function() pickFiles;

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  List<String>? _selectedFileNames;
  UploadZoneStatus _status = UploadZoneStatus.idle;
  String? _errorMessage;
  CaseDetail? _uploadedCase;

  bool get _isBusy => _status != UploadZoneStatus.idle;

  Future<void> _pickFiles() async {
    final fileNames = await widget.pickFiles();
    if (fileNames == null || !mounted) return;
    setState(() {
      _selectedFileNames = fileNames;
      _errorMessage = null;
      _uploadedCase = null;
    });
  }

  Future<void> _upload() async {
    final fileNames = _selectedFileNames;
    if (fileNames == null || fileNames.isEmpty) return;

    setState(() {
      _status = UploadZoneStatus.uploading;
      _errorMessage = null;
      _uploadedCase = null;
    });

    try {
      // A fixed choreography, not a real progress signal -- there's no
      // backend yet to report one, only the one mocked repository call.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _status = UploadZoneStatus.analyzing);

      final detail = await ref.read(uploadServiceProvider).uploadStudy(fileNames);
      if (!mounted) return;
      setState(() {
        _status = UploadZoneStatus.idle;
        _uploadedCase = detail;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = UploadZoneStatus.idle;
        _errorMessage = 'Upload failed. Please try again.';
      });
    }
  }

  void _viewStudy() {
    final detail = _uploadedCase;
    if (detail == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StudyReviewPage(caseId: detail.caseSummary.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedFileNames?.isNotEmpty ?? false;
    return PopScope(
      // An upload in progress shouldn't be abandoned by an accidental
      // back-swipe -- no cancel affordance, matching that decision.
      canPop: !_isBusy,
      child: UploadTemplate(
        appBar: AppBar(title: const Text('Upload a Study')),
        uploadZone: UploadZone(
          status: _status,
          selectedFileNames: _selectedFileNames,
          onTap: _pickFiles,
        ),
        actionButton: AppButton(
          label: 'Upload',
          isLoading: _isBusy,
          onPressed: hasSelection && !_isBusy ? _upload : null,
        ),
        statusBar: _uploadedCase != null
            ? StatusBar(
                message: 'Study processed successfully',
                variant: StatusBannerVariant.success,
                actionLabel: 'View Study',
                onAction: _viewStudy,
              )
            : _errorMessage != null
                ? StatusBar(
                    message: _errorMessage!,
                    variant: StatusBannerVariant.error,
                    actionLabel: 'Retry',
                    onAction: _upload,
                  )
                : null,
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'upload', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewUploadPage() => const UploadPage();
