import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/mocks/case_mocks.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';

void main() {
  group('MockUploadRepository', () {
    test('returns a CaseDetail for the uploaded files', () async {
      final repository = MockUploadRepository();
      final detail = await repository.uploadStudy(['1.dcm', '2.dcm', '3.dcm']);

      expect(detail.caseSummary.title, contains('3'));
      expect(detail.imageUrl, isNotEmpty);
    });

    test('appends the new case to the shared mock case list', () async {
      final repository = MockUploadRepository();
      final before = mockCases.length;

      final detail = await repository.uploadStudy(['1.dcm']);

      expect(mockCases.length, before + 1);
      expect(mockCases.last.id, detail.caseSummary.id);
    });

    test('each upload gets a distinct id', () async {
      final repository = MockUploadRepository();
      final first = await repository.uploadStudy(['1.dcm']);
      final second = await repository.uploadStudy(['2.dcm']);

      expect(first.caseSummary.id, isNot(second.caseSummary.id));
    });
  });
}
