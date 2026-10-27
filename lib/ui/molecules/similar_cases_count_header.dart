import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// The "N similar cases found" header above Similar Cases' results. Not a
/// styling decision for the page to make — it passes only the counts, this
/// owns the pluralization and the token choice, since a page must not style
/// content directly.
///
/// When the search used only some of the study's images, a second line says
/// so ("Based on 2 of 3 images; 1 held back for review"), so a radiologist
/// can tell the results stand on part of the study.
class SimilarCasesCountHeader extends StatelessWidget {
  const SimilarCasesCountHeader({
    super.key,
    required this.count,
    required this.imagesUsed,
    required this.imagesTotal,
    required this.imagesHeldBack,
  });

  final int count;
  final int imagesUsed;
  final int imagesTotal;
  final int imagesHeldBack;

  String get _basis {
    final images = imagesTotal == 1 ? 'image' : 'images';
    final heldBack =
        imagesHeldBack > 0 ? '; $imagesHeldBack held back for review' : '';
    return 'Based on $imagesUsed of $imagesTotal $images$heldBack';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final heading = AppText(
      '$count similar ${count == 1 ? 'case' : 'cases'} found',
      style: AppTypography.headingSm,
      color: colors.textPrimary,
    );
    if (imagesUsed >= imagesTotal) return heading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading,
        const SizedBox(height: AppSpacing.xs),
        AppText(
          _basis,
          style: AppTypography.bodyMd,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}
