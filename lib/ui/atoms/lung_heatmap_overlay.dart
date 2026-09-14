import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';

// Fractions of the canvas, not hardcoded pixels -- lung fields in a standard
// PA/AP chest X-ray span roughly this much of the frame (confirmed against
// real films, not guessed).
const _lungTop = 0.10;
const _lungBottom = 0.78;
const _lungOuterLeft = 0.16;
const _lungOuterRight = 0.84;
const _midGap = 0.03; // half-gap either side of the spine/mediastinum

/// One lobe's bounds, as a rounded rect with asymmetric corners: tighter
/// (more angular) on the medial side, near the spine; looser (more rounded)
/// on the lateral side, following the curve of the rib cage -- reads as
/// lung-shaped rather than a plain symmetric oval. Exposed (not private) so
/// its geometry can be checked directly in tests without hit-testing a Path.
@visibleForTesting
RRect lungLobeRect(Size size, {required bool onRight}) {
  final top = size.height * _lungTop;
  final bottom = size.height * _lungBottom;
  final medial = size.width * (0.5 + (onRight ? _midGap : -_midGap));
  final lateral = size.width * (onRight ? _lungOuterRight : _lungOuterLeft);
  final rect = Rect.fromLTRB(
    onRight ? medial : lateral,
    top,
    onRight ? lateral : medial,
    bottom,
  );
  final medialRadius = Radius.circular(size.width * 0.03);
  final lateralRadius = Radius.circular(size.width * 0.16);
  return RRect.fromRectAndCorners(
    rect,
    topLeft: onRight ? medialRadius : lateralRadius,
    topRight: onRight ? lateralRadius : medialRadius,
    bottomLeft: onRight ? medialRadius : lateralRadius,
    bottomRight: onRight ? lateralRadius : medialRadius,
  );
}

/// Paints the "AI attention" heatmap confined to two lung-shaped regions
/// instead of a flat rectangle, so it reads as sitting over the chest rather
/// than wallpapering the whole image. The silhouette itself is fixed/generic
/// -- real per-image segmentation is out of scope for this mock.
/// [focusAlignment] is the one per-finding variable: where the overlay's
/// intensity peaks within that silhouette.
class LungHeatmapOverlay extends StatelessWidget {
  const LungHeatmapOverlay({
    super.key,
    required this.color,
    this.focusAlignment = Alignment.center,
  });

  final Color color;
  final Alignment focusAlignment;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _LungHeatmapPainter(color, focusAlignment),
    );
  }
}

class _LungHeatmapPainter extends CustomPainter {
  _LungHeatmapPainter(this.color, this.focusAlignment);

  final Color color;
  final Alignment focusAlignment;

  @override
  void paint(Canvas canvas, Size size) {
    final lungs = Path.combine(
      PathOperation.union,
      Path()..addRRect(lungLobeRect(size, onRight: false)),
      Path()..addRRect(lungLobeRect(size, onRight: true)),
    );

    // Radial gradient centered on the finding's focal point, not a flat
    // fill -- brightest at one spot, fading out, same as the rest of this
    // app's overlays never being a uniform wash.
    final center = focusAlignment.withinRect(Offset.zero & size);
    final radius = size.shortestSide * 0.45;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.clipPath(lungs);
    canvas.drawRect(Offset.zero & size, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LungHeatmapPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.focusAlignment != focusAlignment;
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'centered', size: Size(320, 320), wrapper: previewWrapper)
Widget previewLungHeatmapOverlayCentered() =>
    const LungHeatmapOverlay(color: Colors.orange);

@Preview(name: 'lower-left focus', size: Size(320, 320), wrapper: previewWrapper)
Widget previewLungHeatmapOverlayFocused() => const LungHeatmapOverlay(
      color: Colors.red,
      focusAlignment: Alignment(-0.6, 0.5),
    );
