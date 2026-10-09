import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/repositories/heatmap_repository.dart';

import 'fixture_result.dart';

/// Mutable -- a test can reassign a result between calls without
/// re-overriding the provider.
class HeatmapRepositoryFixture implements HeatmapRepository {
  HeatmapRepositoryFixture({this.getHeatmapResult});

  FixtureResult<HeatmapData>? getHeatmapResult;

  @override
  Future<HeatmapData> getHeatmap(String findingId) =>
      getHeatmapResult?.resolve() ?? _unconfigured('getHeatmap');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'HeatmapRepositoryFixture.$method not configured for this test');
