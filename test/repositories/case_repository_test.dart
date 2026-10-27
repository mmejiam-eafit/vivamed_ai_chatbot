import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';

void main() {
  group('MockCaseRepository.getSimilarCases', () {
    test('excludes the given case', () async {
      final repository = MockCaseRepository();
      final similar = await repository.getSimilarCases('case-1');
      expect(similar.cases.any((c) => c.id == 'case-1'), isFalse);
    });

    test('returns up to 3 other cases', () async {
      final repository = MockCaseRepository();
      final similar = await repository.getSimilarCases('case-1');
      expect(similar.cases.length, 3);
      expect(similar.cases.length, lessThanOrEqualTo(mockCases.length - 1));
    });

    test('a study with nothing held back is searched with its one image',
        () async {
      final similar = await MockCaseRepository().getSimilarCases('case-1');
      expect(similar.imagesUsed, 1);
      expect(similar.imagesTotal, 1);
      expect(similar.imagesHeldBack, 0);
    });

    test('a study with an image held back is searched with the others',
        () async {
      final similar = await MockCaseRepository().getSimilarCases('case-7');
      expect(similar.imagesUsed, 2);
      expect(similar.imagesTotal, 3);
      expect(similar.imagesHeldBack, 1);
      expect(similar.cases, isNotEmpty);
    });

    test('a study held back entirely has no similar cases', () async {
      final similar = await MockCaseRepository().getSimilarCases('case-6');
      expect(similar.imagesUsed, 0);
      expect(similar.imagesHeldBack, 1);
      expect(similar.cases, isEmpty);
    });
  });
}
