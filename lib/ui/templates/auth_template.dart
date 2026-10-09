import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

class AuthTemplate extends StatelessWidget {
  const AuthTemplate({super.key, required this.formContent});

  final Widget formContent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surfacePage,
      // resizeToAvoidBottomInset (Scaffold's default) plus a scrollable body
      // is what lets compact scroll the form above the keyboard (DT §9.5).
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact =
              constraints.maxWidth.layoutTier == AppLayoutTier.compact;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              // Compact: full-bleed, no card, no shadow — just the margin
              // above. Medium and up: a centered card at formMaxWidth; DT
              // §9.5 asks for ultrawide to center that same card inside a
              // wider 640 column, which is indistinguishable from centering
              // it directly whenever the content is already narrower than
              // 640, as it is here — so there is nothing further to build.
              child: isCompact
                  ? formContent
                  : ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: AppLayout.formMaxWidth),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppRadius.borderPanel,
                        ),
                        child: formContent,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
