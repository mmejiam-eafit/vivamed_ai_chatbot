import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// The compact-tier findings bottom sheet DT §9.5 specifies as draggable.
/// Wraps `child` (typically a `FindingsPanel`) in a `DraggableScrollableSheet`.
///
/// The drag handle — not `child` — is the thing connected to the sheet's own
/// `scrollController`, wrapped in a `shrinkWrap` `SingleChildScrollView` just
/// large enough for the handle itself. `DraggableScrollableController` only
/// resizes the sheet through an actually-attached `Scrollable`'s overscroll
/// (confirmed against the Flutter SDK source: `isAttached` requires a
/// connected `ScrollPosition`, not just a controller reference) — so the
/// handle needs *a* connected scrollable, just not `child`'s own. `child`
/// already scrolls itself internally with no external hook for one; wrapping
/// it in the sheet's scrollController too would nest two independent
/// scroll mechanisms fighting over the same gesture.
class DraggableFindingsSheet extends StatelessWidget {
  const DraggableFindingsSheet({
    super.key,
    required this.child,
    required this.availableHeight,
  });

  final Widget child;

  /// The screen height this sheet's parent has available. Unused by the
  /// sheet mechanism itself (which works in fractions of its own layout
  /// height) — kept as an explicit parameter so callers don't need to
  /// know that detail, and so a future snap-point or fixed-height feature
  /// has it on hand without a signature change.
  final double availableHeight;

  static const double initialSize = 0.4;
  static const double minSize = 0.08;
  static const double maxSize = 0.9;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadius.sheet),
            topRight: Radius.circular(AppRadius.sheet),
          ),
        ),
        child: Column(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.borderSubdued,
                      borderRadius: AppRadius.borderInput,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
