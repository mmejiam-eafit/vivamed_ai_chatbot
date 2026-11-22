import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/focus_ring.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// A checkbox. [value] null is the third state of a "select all" whose items
/// are only partly selected; tapping it selects them all.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.focusNode,
  });

  final bool? value;

  /// Called with the value the checkbox moves to: true from unchecked or
  /// partly checked, false from checked. Null disables the checkbox.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    return FocusRing(
      borderRadius: BorderRadius.circular(
        AppRadius.inlineElement + AppInteraction.focusRingOffset,
      ),
      // The box is small; the target around it is the 44px floor (DL §8.5).
      child: SizedBox.square(
        dimension: AppInteraction.minTouchTarget,
        child: Checkbox(
          value: value,
          tristate: true,
          onChanged:
              onChanged == null ? null : (_) => onChanged(!(value ?? false)),
          semanticLabel: semanticLabel,
          focusNode: focusNode,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: colors.interactivePrimary,
          checkColor: colors.interactivePrimaryForeground,
          // The outline carries the control's meaning, so it takes the
          // meaningful border, not the decorative one; 2.0 keeps Material's
          // own checkbox stroke.
          side: BorderSide(color: colors.border, width: 2.0),
          mouseCursor: onChanged == null
              ? AppInteraction.mouseForbidden
              : AppInteraction.mousePointer,
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'unchecked', size: Size(80, 80), wrapper: previewWrapper)
Widget previewAppCheckboxUnchecked() =>
    AppCheckbox(value: false, onChanged: (_) {});

@Preview(name: 'checked', size: Size(80, 80), wrapper: previewWrapper)
Widget previewAppCheckboxChecked() =>
    AppCheckbox(value: true, onChanged: (_) {});

@Preview(name: 'partly checked', size: Size(80, 80), wrapper: previewWrapper)
Widget previewAppCheckboxPartial() =>
    AppCheckbox(value: null, onChanged: (_) {});

@Preview(name: 'disabled', size: Size(80, 80), wrapper: previewWrapper)
Widget previewAppCheckboxDisabled() =>
    const AppCheckbox(value: false, onChanged: null);
