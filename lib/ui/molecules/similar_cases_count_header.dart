import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// The "N similar cases found" header above Similar Cases' results. Not a
/// styling decision for the page to make — it passes only the count, this
/// owns the pluralization and the token choice, since a page must not style
/// content directly.
class SimilarCasesCountHeader extends StatelessWidget {
  const SimilarCasesCountHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppText(
      '$count similar ${count == 1 ? 'case' : 'cases'} found',
      style: AppTypography.headingSm,
      color: context.colors.textPrimary,
    );
  }
}
