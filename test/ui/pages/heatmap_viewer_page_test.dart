import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  group('HeatmapViewerPage', () {
    testWidgets('renders HeatmapViewerTemplate', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      expect(find.byType(HeatmapViewerTemplate), findsOneWidget);
    });

    testWidgets('renders Heatmap in app bar', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      expect(find.text('Heatmap'), findsOneWidget);
    });

    testWidgets('renders Slider opacity control', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('slider initial value is 0.5', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.5);
    });

    testWidgets('renders a heatmap overlay once mock data resolves',
        (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      final template = tester.widget<HeatmapViewerTemplate>(
        find.byType(HeatmapViewerTemplate),
      );
      expect(template.heatmapOverlay, isNotNull);
    });

    testWidgets('Scaffold has bottomNavigationBar for opacity control',
        (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isNotNull);
    });

    testWidgets('slider interaction updates opacity state', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.5);

      // Drag the slider to a new position
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pump();

      final updatedSlider = tester.widget<Slider>(find.byType(Slider));
      expect(updatedSlider.value, isNot(0.5));
    });

    testWidgets('only one HeatmapViewerTemplate is instantiated',
        (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage()));
      await tester.pumpAndSettle();

      expect(find.byType(HeatmapViewerTemplate), findsOneWidget);
    });
  });
}
