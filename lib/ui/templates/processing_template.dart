import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/failure_action_bar.dart';
import 'package:radiologist_helper/ui/organisms/status_bar.dart';

/// A study's processing: the run's progress, then its failed items, in one
/// top-aligned column capped at `contentMaxWidth` at every width (DT §9.5).
/// While items are selected, the action bar is pinned full width to the
/// bottom. A drill-down page, so the app bar stays at every tier.
class ProcessingTemplate extends StatelessWidget {
  const ProcessingTemplate({
    super.key,
    required this.appBar,
    required this.failures,
    this.statusBar,
    this.progress,
    this.actionBar,
  });

  final PreferredSizeWidget appBar;

  /// The failed items, or the message standing in for them while they load.
  final Widget failures;

  /// The outcome of the last action, above the content.
  final Widget? statusBar;

  /// The run's progress, when the page follows a run.
  final Widget? progress;

  /// What to do with the selected items; absent while nothing is selected.
  final Widget? actionBar;

  @override
  Widget build(BuildContext context) {
    final actionBar = this.actionBar;
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      bottomNavigationBar:
          actionBar == null ? null : SafeArea(top: false, child: actionBar),
      body: Column(
        // stretch: the status bar spans the width instead of floating at its
        // own (DT §9.5).
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?statusBar,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              // Centered horizontally only: the column is read from the top
              // down, so it starts under the app bar (DT §9.5).
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (progress case final progress?) ...[
                        progress,
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      failures,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _placeholder(String label, double height) => SizedBox(
      height: height,
      child: Card(child: Center(child: Text(label))),
    );

@Preview(name: 'items selected', size: Size(390, 700), wrapper: previewWrapperFull)
Widget previewProcessingTemplate() => ProcessingTemplate(
      appBar: AppBar(title: const Text('Processing')),
      statusBar: const StatusBar(message: 'Retrying 1 item.'),
      progress: _placeholder('Progress', 240),
      failures: _placeholder('Failed items', 200),
      actionBar: FailureActionBar(
        selectedCount: 2,
        retryableCount: 2,
        onRetry: () {},
        onDiscard: () {},
      ),
    );
