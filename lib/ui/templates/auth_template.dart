import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

class AuthTemplate extends StatelessWidget {
  const AuthTemplate({super.key, required this.formContent});

  final Widget formContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfacePage,
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
                          color: AppColors.surface,
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

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'sign in', size: Size(480, 560), wrapper: previewWrapperFull)
Widget previewAuthTemplate() => AuthTemplate(
      formContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppText(
            'Radiologist Helper',
            style: AppTypography.headingLg,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          const AppText(
            'Sign in to your account',
            style: AppTypography.bodySm,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: TextEditingController(),
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: TextEditingController(),
            hintText: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(label: 'Sign in', onPressed: () {}),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: AppText(
              'Forgot your password?',
              style: AppTypography.bodySm,
              color: AppColors.textLink,
            ),
          ),
        ],
      ),
    );
