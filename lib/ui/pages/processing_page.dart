import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/repositories/processing_repository.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/status_banner.dart';
import 'package:radiologist_helper/ui/organisms/failure_action_bar.dart';
import 'package:radiologist_helper/ui/organisms/failure_list.dart';
import 'package:radiologist_helper/ui/organisms/run_progress_card.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/processing_template.dart';

enum _Action { retry, discard }

/// What happens to a study after its upload: the run's progress while the
/// pipeline works, and the study's failed items, to retry or discard.
/// Opened right after an upload, following its run, and from Study Review
/// while the study has open failures.
class ProcessingPage extends ConsumerStatefulWidget {
  const ProcessingPage({super.key, required this.caseId, this.runId});

  final String caseId;

  /// The run to follow, when the page opens from an upload. Without one,
  /// the page shows the study's failed items only.
  final String? runId;

  @override
  ConsumerState<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends ConsumerState<ProcessingPage> {
  var _selected = <String>{};
  var _busy = false;
  ({String message, StatusBannerVariant variant})? _status;

  static final _appBar = AppBar(title: const Text('Processing'));

  static String _items(int count) => count == 1 ? '1 item' : '$count items';

  static String _changed(int count) => count == 1
      ? '1 selected item had already changed'
      : '$count selected items had already changed';

  /// Runs [action], then shows its outcome. Nothing the user sees changes
  /// until the refreshed list has arrived: the reload itself rebuilds the
  /// page, so the outcome, the cleared selection and the end of the busy state
  /// are applied together afterwards, never against the old list.
  Future<void> _act(_Action action, List<String> stepIds) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    final service = ref.read(processingServiceProvider);
    ({String message, StatusBannerVariant variant}) status;
    var done = false;
    try {
      switch (action) {
        case _Action.retry:
          await service.retry(stepIds);
          status = (
            message: 'Retrying ${_items(stepIds.length)}.',
            variant: StatusBannerVariant.info,
          );
        case _Action.discard:
          await service.discard(stepIds);
          status = (
            message: 'Discarded ${_items(stepIds.length)}.',
            variant: StatusBannerVariant.success,
          );
      }
      done = true;
      // A retry reopens the run and a discard changes its counts, so read
      // it again.
      if (widget.runId case final runId?) {
        ref.invalidate(processingRunProvider(runId));
      }
      await _reloadFailures();
    } on StepConflictException catch (conflict) {
      status = (
        message: '${_changed(conflict.stepIds.length)}, so nothing was done. '
            'The list has been refreshed.',
        variant: StatusBannerVariant.warning,
      );
      await _reloadFailures();
    } catch (error) {
      final verb = action == _Action.retry ? 'retry' : 'discard';
      status = (
        message: 'Could not $verb: $error',
        variant: StatusBannerVariant.error,
      );
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = status;
      if (done) _selected = {};
    });
  }

  /// Waits for the new list before leaving the busy state, so the selection
  /// never meets the old one in between.
  Future<void> _reloadFailures() async {
    ref.invalidate(processingFailuresProvider);
    try {
      await ref.read(processingFailuresProvider.future);
    } catch (_) {
      // The list shows its own error.
    }
  }

  void _openStudy() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StudyReviewPage(caseId: widget.caseId),
        ),
      );

  /// Follows the run: its failures appear on the list as they happen, and
  /// once it ends, any images it held back reach the review queue.
  void _listenToRun(String runId) {
    ref.listen(processingRunProvider(runId), (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (after == null) return;
      if (before?.openFailures != after.openFailures) {
        ref.invalidate(processingFailuresProvider);
      }
      if (after.status.ended && before?.status.ended != true) {
        ref.invalidate(imageReviewsProvider);
      }
    });
  }

  Widget? _progress(String? runId) {
    if (runId == null) return null;
    final runAsync = ref.watch(processingRunProvider(runId));
    if (runAsync.value case final run?) {
      return RunProgressCard(
        run: run,
        refreshError: runAsync.hasError
            ? 'Could not refresh the progress: ${runAsync.error}'
            : null,
        onOpenStudy: _openStudy,
      );
    }
    if (runAsync.hasError) {
      return Center(
        child: AppText('Could not load the progress: ${runAsync.error}'),
      );
    }
    return const Center(child: AppLoadingIndicator());
  }

  @override
  Widget build(BuildContext context) {
    final runId = widget.runId;
    if (runId != null) _listenToRun(runId);

    final failuresAsync = ref.watch(processingFailuresProvider);
    final failures = failuresAsync.value?[widget.caseId] ?? const [];
    // Only what is still listed counts: a step another radiologist acted on
    // leaves the selection with the list.
    final selected = _selected.intersection({
      for (final f in failures) f.stepId,
    });
    final retryable = [
      for (final f in failures)
        if (selected.contains(f.stepId) && f.canRetry) f.stepId,
    ];

    return ProcessingTemplate(
      appBar: _appBar,
      statusBar: switch (_status) {
        final status? => StatusBar(
            message: status.message,
            variant: status.variant,
          ),
        null => null,
      },
      progress: _progress(runId),
      failures: failuresAsync.when(
        data: (_) => FailureList(
          failures: failures,
          selectedIds: selected,
          onSelectionChanged:
              _busy ? null : (ids) => setState(() => _selected = ids),
        ),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, _) =>
            Center(child: AppText('Could not load the failed items: $error')),
      ),
      actionBar: selected.isEmpty
          ? null
          : FailureActionBar(
              selectedCount: selected.length,
              retryableCount: retryable.length,
              isBusy: _busy,
              onRetry: () => _act(_Action.retry, retryable),
              onDiscard: () => _act(_Action.discard, selected.toList()),
            ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(
    name: 'case-6 failures', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewProcessingPage() => const ProcessingPage(caseId: 'case-6');
