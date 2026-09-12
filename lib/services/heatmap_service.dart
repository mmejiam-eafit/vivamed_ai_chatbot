import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/repositories/heatmap_repository.dart';

class HeatmapService {
  HeatmapService(this._heatmapRepository);

  final HeatmapRepository _heatmapRepository;

  Future<HeatmapData> getHeatmap(String findingId) =>
      _heatmapRepository.getHeatmap(findingId);
}
