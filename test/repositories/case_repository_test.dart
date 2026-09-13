import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';

void main() {
  group('MockCaseRepository.getSimilarCases', () {
    test('excludes the given case', () async {
      final repository = MockCaseRepository();
      final similar = await repository.getSimilarCases('case-1');
      expect(similar.any((c) => c.id == 'case-1'), isFalse);
    });

    test('returns up to 3 other cases', () async {
      final repository = MockCaseRepository();
      final similar = await repository.getSimilarCases('case-1');
      expect(similar.length, 3);
      expect(similar.length, lessThanOrEqualTo(mockCases.length - 1));
    });
  });
}
