import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

/// Where a radiologist decides about one flagged image (DT §9.5). The canvas
/// shows the flagged image beside the study's other images at every width --
/// a PA next to a lateral is what settles most of these -- and the decision
/// and report sit beside the canvas from `twoPaneMinWidth`, below it under
/// that.
///
/// A drill-down page reached from the review queue or Study Review, so its
/// app bar stays at every tier, as the Heatmap Viewer's does, to keep a way
/// back.
class ImageReviewTemplate extends StatelessWidget {
  const ImageReviewTemplate({
    super.key,
    required this.appBar,
    required this.flaggedImage,
    required this.otherImages,
    required this.reviewPanel,
    required this.reportSections,
  });

  final PreferredSizeWidget appBar;

  /// The flagged image, given two thirds of the canvas.
  final Widget flaggedImage;

  /// The study's other images, stacked in the remaining third. With none,
  /// the flagged image takes the whole canvas.
  final List<Widget> otherImages;

  /// The ImageReviewPanel organism.
  final Widget reviewPanel;

  /// The study's report, one widget per section, in display order.
  final List<Widget> reportSections;

  /// The canvas holds evidence, so it is dark in both modes (DL §3.7, D-004);
  /// its captions read the dark theme's tokens, as the Heatmap Viewer's
  /// chrome does (design_tokens.md §10.2).
  static final ThemeData _forcedDark = buildAppTheme(Brightness.dark);

  /// The canvas's share of the height below `twoPaneMinWidth`, as in Study
  /// Review: enough to compare the images while the decision scrolls below.
  static const double _narrowCanvasHeightFraction = 0.45;

  Widget _canvas() {
    return Theme(
      data: _forcedDark,
      child: ColoredBox(
        color: diagnosticCanvasGround,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: flaggedImage),
              if (otherImages.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, image) in otherImages.indexed) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.sm),
                        Expanded(child: image),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _details() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        reviewPanel,
        for (final section in reportSections) ...[
          const SizedBox(height: AppSpacing.lg),
          section,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfacePage,
      appBar: appBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= AppLayout.twoPaneMinWidth) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _canvas()),
                const AppDivider(axis: Axis.vertical),
                SizedBox(width: AppLayout.panelMaxWidth, child: _details()),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: constraints.maxHeight * _narrowCanvasHeightFraction,
                child: _canvas(),
              ),
              Expanded(child: _details()),
            ],
          );
        },
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

Widget _previewTemplate() => ImageReviewTemplate(
      appBar: AppBar(title: const Text('Image review')),
      flaggedImage: const Placeholder(),
      otherImages: const [Placeholder(), Placeholder()],
      reviewPanel: const SizedBox(height: 400, child: Placeholder()),
      reportSections: const [SizedBox(height: 120, child: Placeholder())],
    );

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewImageReviewTemplateNarrow() => _previewTemplate();

@Preview(name: 'wide', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewImageReviewTemplateWide() => _previewTemplate();
