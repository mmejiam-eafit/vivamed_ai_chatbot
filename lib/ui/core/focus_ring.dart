import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Offset focus ring shared by every focusable atom and molecule — sits
/// outside the control so it reads against the page regardless of the
/// control's own fill (DL §8.4).
///
/// Parasitic on the wrapped widget's own focusability, not a second source
/// of truth for it: this ring's own [Focus] node never requests focus itself
/// (`canRequestFocus: false`), so [Focus.hasFocus] here is only ever true
/// because a descendant — the real button, field, or chip — holds focus.
/// A disabled button or a `NavItem` with no `onTap` is therefore never
/// focusable in the first place, and this ring correctly never shows for
/// either, with no separate enabled/disabled plumbing required here.
class FocusRing extends StatelessWidget {
  const FocusRing({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return Container(
            padding: const EdgeInsets.all(AppInteraction.focusRingOffset),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasFocus
                    ? context.colors.borderFocused
                    : Colors.transparent,
                width: AppInteraction.focusRingWidth,
              ),
              borderRadius: borderRadius,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
