import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/data/mocks/heatmap_mocks.dart';

abstract class HeatmapRepository {
  /// Keyed by finding, not case -- per the app's own Flow proposal and DT's
  /// framing of the heatmap as per-finding.
  Future<HeatmapData> getHeatmap(String findingId);
}

class MockHeatmapRepository implements HeatmapRepository {
  @override
  Future<HeatmapData> getHeatmap(String findingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockHeatmapFor(findingId);
  }
}
