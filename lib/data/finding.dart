import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

class FindingItem {
  const FindingItem({required this.id, required this.name, required this.severity});

  final String id;
  final String name;
  final SeverityLevel severity;
}
