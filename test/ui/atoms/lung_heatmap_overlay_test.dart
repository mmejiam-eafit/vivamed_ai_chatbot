import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/atoms/lung_heatmap_overlay.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: SizedBox(width: 300, height: 500, child: child)),
      );

  testWidgets('renders a CustomPaint, not a flat rectangle', (tester) async {
    await tester
        .pumpWidget(wrap(const LungHeatmapOverlay(color: Colors.orange)));
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  // ── lungLobeRect geometry ────────────────────────────────────────────────
  // Checked directly rather than by hit-testing a Path, since the shape
  // can't be eyeballed from a screenshot in this environment.

  const size = Size(400, 600);

  test('left and right lobes mirror across the vertical midline', () {
    final left = lungLobeRect(size, onRight: false);
    final right = lungLobeRect(size, onRight: true);

    expect(left.top, right.top);
    expect(left.bottom, right.bottom);
    expect(size.width - left.left, right.right); // mirrored outer edges
    expect(size.width - left.right, right.left); // mirrored inner edges
  });

  test('lobes stop short of the midline (a gap over the spine)', () {
    final left = lungLobeRect(size, onRight: false);
    final right = lungLobeRect(size, onRight: true);

    expect(left.right, lessThan(size.width / 2));
    expect(right.left, greaterThan(size.width / 2));
  });

  test('lobes stay within the canvas bounds', () {
    for (final onRight in [false, true]) {
      final lobe = lungLobeRect(size, onRight: onRight);
      expect(lobe.left, greaterThanOrEqualTo(0));
      expect(lobe.right, lessThanOrEqualTo(size.width));
      expect(lobe.top, greaterThanOrEqualTo(0));
      expect(lobe.bottom, lessThanOrEqualTo(size.height));
    }
  });

  test('lobes are taller than they are wide (not a flat wash)', () {
    for (final onRight in [false, true]) {
      final lobe = lungLobeRect(size, onRight: onRight);
      expect(lobe.height, greaterThan(lobe.width));
    }
  });
}
