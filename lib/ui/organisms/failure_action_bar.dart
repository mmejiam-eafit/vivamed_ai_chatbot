import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

enum _Action { retry, discard }

/// What to do with the selected failed items: retry them, or discard them.
///
/// Retry counts only the items that can be retried, and says so when some of
/// the selection can't, so the app never asks for a retry the pipeline is
/// bound to refuse. Discard cannot be undone, so it asks once more, here in
/// the bar rather than in a dialog (DL D-023, §7.3).
class FailureActionBar extends StatefulWidget {
  const FailureActionBar({
    super.key,
    required this.selectedCount,
    required this.retryableCount,
    required this.onRetry,
    required this.onDiscard,
    this.isBusy = false,
  });

  final int selectedCount;

  /// How many of the selected items can be retried.
  final int retryableCount;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  /// An action is running: both are disabled, the one running shows it.
  final bool isBusy;

  @override
  State<FailureActionBar> createState() => _FailureActionBarState();
}

class _FailureActionBarState extends State<FailureActionBar> {
  var _confirmingDiscard = false;
  _Action? _running;

  static String _items(int count) => count == 1 ? '1 item' : '$count items';

  static String _cannotRetry(int count) => count == 1
      ? "1 selected item can't be retried. Upload its file again."
      : "$count selected items can't be retried. Upload their files again.";

  void _retry() {
    _running = _Action.retry;
    widget.onRetry();
  }

  void _discard() {
    setState(() {
      _confirmingDiscard = false;
      _running = _Action.discard;
    });
    widget.onDiscard();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final busy = widget.isBusy;
    final cannotRetry = widget.selectedCount - widget.retryableCount;

    final List<Widget> buttons;
    final String prompt;
    if (_confirmingDiscard) {
      prompt = 'Discard ${_items(widget.selectedCount)}? '
          "Discarded items can't be retried.";
      buttons = [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => setState(() => _confirmingDiscard = false),
        ),
        AppButton(label: 'Discard', onPressed: _discard),
      ];
    } else {
      prompt = '${widget.selectedCount} selected';
      buttons = [
        AppButton(
          label: 'Discard ${widget.selectedCount}',
          variant: AppButtonVariant.secondary,
          isLoading: busy && _running == _Action.discard,
          onPressed:
              busy ? null : () => setState(() => _confirmingDiscard = true),
        ),
        AppButton(
          label: 'Retry ${widget.retryableCount}',
          isLoading: busy && _running == _Action.retry,
          onPressed: busy || widget.retryableCount == 0 ? null : _retry,
        ),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppElevation.raised,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cannotRetry > 0 && !_confirmingDiscard) ...[
            AppText(
              _cannotRetry(cannotRetry),
              style: AppTypography.bodySm,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          // Wraps rather than overflowing: at large text sizes or on a
          // narrow screen the buttons move under the prompt.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppText(
                prompt,
                style: AppTypography.bodyMd,
                color: colors.textPrimary,
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: buttons,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(
    name: 'some not retryable', size: Size(390, 140), wrapper: previewWrapper)
Widget previewFailureActionBar() => FailureActionBar(
      selectedCount: 3,
      retryableCount: 2,
      onRetry: () {},
      onDiscard: () {},
    );
