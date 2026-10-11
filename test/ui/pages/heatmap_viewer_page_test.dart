import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/repositories/heatmap_repository.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

class _FailingHeatmapRepository implements HeatmapRepository {
  @override
  Future<HeatmapData> getHeatmap(String findingId) async {
    throw Exception('mock failure');
  }
}

class _FixedHeatmapRepository implements HeatmapRepository {
  _FixedHeatmapRepository(this.data);

  final HeatmapData data;

  @override
  Future<HeatmapData> getHeatmap(String findingId) async => data;
}

class _PendingHeatmapRepository implements HeatmapRepository {
  @override
  Future<HeatmapData> getHeatmap(String findingId) => Completer<HeatmapData>().future;
}

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  group('HeatmapViewerPage', () {
    testWidgets('renders HeatmapViewerTemplate', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      expect(find.byType(HeatmapViewerTemplate), findsOneWidget);
    });

    testWidgets('renders Heatmap in app bar', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      expect(find.text('Heatmap'), findsOneWidget);
    });

    testWidgets('renders Slider opacity control', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('slider initial value is 0.5', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.value, 0.5);
    });

    testWidgets('renders a heatmap overlay once mock data resolves',
        (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      final template = tester.widget<HeatmapViewerTemplate>(
        find.byType(HeatmapViewerTemplate),
      );
      expect(template.heatmapOverlay, isNotNull);
    });

    // The whole study is shown, never cropped (DL D-020): the page hands the
    // template the study's own ratio and a non-cropping fit. A ratio other than
    // the mocks' 1.0 proves it is read from the data, not defaulted.
    testWidgets('lays the image out at the data\'s own aspect ratio, uncropped',
        (tester) async {
      await tester.pumpWidget(wrap(
        const HeatmapViewerPage(findingId: 'finding-1'),
        overrides: [
          heatmapRepositoryProvider.overrideWithValue(
            _FixedHeatmapRepository(const HeatmapData(
              baseImageUrl: 'lib/data/mocks/images/case-1.png',
              overlayColor: Colors.red,
              imageAspectRatio: 4 / 3,
            )),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      final template = tester.widget<HeatmapViewerTemplate>(
        find.byType(HeatmapViewerTemplate),
      );
      expect(template.imageAspectRatio, 4 / 3);
      expect(tester.widget<AppImage>(find.byType(AppImage)).fit, BoxFit.contain);
    });

    testWidgets('Scaffold has bottomNavigationBar for opacity control',
        (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isNotNull);
    });

    testWidgets('slider interaction updates opacity state', (tester) async {
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
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
      await tester.pumpWidget(wrap(const HeatmapViewerPage(findingId: 'finding-1')));
      await tester.pumpAndSettle();

      expect(find.byType(HeatmapViewerTemplate), findsOneWidget);
    });

    testWidgets('while the heatmap is still loading, shows a loading indicator',
        (tester) async {
      await tester.pumpWidget(wrap(
        const HeatmapViewerPage(findingId: 'finding-1'),
        overrides: [
          heatmapRepositoryProvider.overrideWithValue(_PendingHeatmapRepository()),
        ],
      ));
      await tester.pump();

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(find.byType(HeatmapViewerTemplate), findsNothing);
    });

    testWidgets('shows an error message when the heatmap fails to load',
        (tester) async {
      await tester.pumpWidget(wrap(
        const HeatmapViewerPage(findingId: 'finding-1'),
        overrides: [
          heatmapRepositoryProvider.overrideWithValue(_FailingHeatmapRepository()),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Could not load heatmap'), findsOneWidget);
      expect(find.byType(HeatmapViewerTemplate), findsNothing);
    });
  });
}
