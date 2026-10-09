import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/templates/heatmap_viewer_template.dart';

import 'fixtures/fixture_result.dart';
import 'fixtures/heatmap_repository_fixture.dart';

/// Fixture-backed scenarios: success path and loading only. The error branch
/// has its own dedicated coverage in
/// `test/ui/pages/heatmap_viewer_page_test.dart`, so this file only adds what
/// existed nowhere else: backend-swap-resilient success/loading scenarios.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  testWidgets('success renders the fixture heatmap overlay', (tester) async {
    final fixture = HeatmapRepositoryFixture(
      getHeatmapResult: const FixtureSuccess(HeatmapData(
        baseImageUrl: 'https://example.invalid/fixture-base.png',
        overlayColor: Color(0xFFAA0000),
        imageAspectRatio: 1.0,
      )),
    );
    await tester.pumpWidget(wrap(
      const HeatmapViewerPage(findingId: 'fixture-finding'),
      overrides: [heatmapRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    final template = tester.widget<HeatmapViewerTemplate>(
      find.byType(HeatmapViewerTemplate),
    );
    expect(template.heatmapOverlay, isNotNull);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    final fixture = HeatmapRepositoryFixture(
      getHeatmapResult: const FixturePending(),
    );
    await tester.pumpWidget(wrap(
      const HeatmapViewerPage(findingId: 'fixture-finding'),
      overrides: [heatmapRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
    expect(find.byType(HeatmapViewerTemplate), findsNothing);
  });
}
