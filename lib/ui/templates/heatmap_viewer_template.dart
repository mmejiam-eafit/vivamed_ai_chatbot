import 'package:flutter/material.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

// The canvas is grounded in diagnosticCanvasGround, which is
// mode-exempt: identical in light and dark. Pixel data is evidence, and the
// perceived contrast of an image depends on its surround, so the surround must
// not move with a user preference (DL §3.7, D-004). It is deliberately not a
// semantic surface token — picking one for being "dark enough" is the
// appearance-based reasoning D-001 forbids.
//
// The chrome around the canvas is forced dark for the same reason, via the
// mechanism design_tokens.md §10.2 specifies for this file.
class HeatmapViewerTemplate extends StatelessWidget {
  const HeatmapViewerTemplate({
    super.key,
    required this.appBar,
    required this.baseImage,
    required this.opacityControl,
    this.heatmapOverlay,
    this.imageAspectRatio,
  });

  final PreferredSizeWidget appBar;
  final Widget baseImage;

  /// Pre-wrapped by the page in `Opacity(opacity: value, child: ...)`.
  /// Null when heatmap data has not yet been received from the backend.
  final Widget? heatmapOverlay;

  /// Slider or custom widget; the page owns the opacity state.
  final Widget opacityControl;

  /// Width divided by height of the base image. When given, the image and the
  /// overlay share one frame at exactly this ratio, centered on the canvas
  /// ground: the whole study is shown, never cropped, and the overlay sits on
  /// the same pixels as the image whatever the window's shape (DL D-020, DT
  /// §9.5). When null both slots fill the canvas, so a `cover`-fit image would
  /// be cropped to it -- pass the ratio whenever it is known.
  final double? imageAspectRatio;

  /// Built once — the viewer's chrome is dark in both modes, so this never
  /// depends on the ambient theme (design_tokens.md §10.2, DL §6.5).
  static final ThemeData _forcedDark = buildAppTheme(Brightness.dark);

  /// Width of the persistent control rail at expanded and up (DT §9.5).
  static const double _railWidth = 280.0;

  /// Explicit control-bar height at compact and medium (DT §9.5), and the
  /// height of the control's own box in the rail. Pinned rather than left
  /// intrinsic because a `Slider` fills whatever height it is given:
  /// `Scaffold.bottomNavigationBar` gives it the whole screen, and the rail's
  /// full-height column gave it ~800px of hit area around a 24px track. The
  /// bar pads only sideways, so the control's box is the full bar: padding it
  /// above and below left a 24px touch area, under `minTouchTarget`.
  static const double _controlBarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    final layers = Stack(
      fit: StackFit.expand,
      children: [
        baseImage,
        ?heatmapOverlay,
      ],
    );
    final ratio = imageAspectRatio;
    final canvas = ratio == null
        ? layers
        : Center(child: AspectRatio(aspectRatio: ratio, child: layers));

    return Theme(
      data: _forcedDark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tier = constraints.maxWidth.layoutTier;
          final isRailTier = tier == AppLayoutTier.expanded ||
              tier == AppLayoutTier.ultrawide;

          if (isRailTier) {
            return Scaffold(
              backgroundColor: diagnosticCanvasGround,
              appBar: appBar,
              body: Row(
                children: [
                  Expanded(child: canvas),
                  Container(
                    width: _railWidth,
                    color: diagnosticCanvasGround,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    // Centered in the rail, as it always rendered: the box is
                    // pinned, the control's place on screen is not changed.
                    child: Center(
                      child: SizedBox(
                        height: _controlBarHeight,
                        child: opacityControl,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final controlBar = Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: opacityControl,
          );
          return Scaffold(
            backgroundColor: diagnosticCanvasGround,
            appBar: appBar,
            body: canvas,
            bottomNavigationBar: ColoredBox(
              color: diagnosticCanvasGround,
              child: SizedBox(height: _controlBarHeight, child: controlBar),
            ),
          );
        },
      ),
    );
  }
}
