import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

CaseSummary _study({int openFailures = 0}) => CaseSummary(
      id: 'case-x',
      title: 'Chest X-Ray',
      patient: 'Anonymous X',
      modality: 'CXR',
      date: DateTime(2026, 11, 1),
      confidence: 0.9,
      severity: SeverityLevel.mild,
      status: StudyStatus.processing,
      openFailures: openFailures,
    );

void main() {
  group('StudyStatus', () {
    test('is declared in the order a radiologist attends to it', () {
      expect(StudyStatus.values, [
        StudyStatus.failed,
        StudyStatus.needsReview,
        StudyStatus.processing,
        StudyStatus.queued,
        StudyStatus.ready,
      ]);
    });

    test('only queued and processing are in progress', () {
      expect(
        StudyStatus.values.where((s) => s.inProgress),
        [StudyStatus.processing, StudyStatus.queued],
      );
    });
  });

  group('CaseSummary', () {
    test('defaults to a ready study with nothing open or under way', () {
      final study = CaseSummary(
        id: 'case-x',
        title: 'Chest X-Ray',
        patient: 'Anonymous X',
        modality: 'CXR',
        date: DateTime(2026, 11, 1),
        confidence: 0.9,
        severity: SeverityLevel.mild,
      );
      expect(study.status, StudyStatus.ready);
      expect(study.openFailures, 0);
      expect(study.activeRunId, isNull);
    });

    test('statusSummary is the label alone without open failures', () {
      expect(_study().statusSummary, 'Processing');
    });

    test('statusSummary counts one failed item', () {
      expect(
          _study(openFailures: 1).statusSummary, 'Processing · 1 failed item');
    });

    test('statusSummary counts several failed items', () {
      expect(
          _study(openFailures: 3).statusSummary, 'Processing · 3 failed items');
    });

    test('withStatus replaces the status and keeps the study', () {
      final study = _study(openFailures: 2).withStatus(
        status: StudyStatus.ready,
        openFailures: 0,
        activeRunId: null,
      );
      expect(study.id, 'case-x');
      expect(study.severity, SeverityLevel.mild);
      expect(study.status, StudyStatus.ready);
      expect(study.openFailures, 0);
      expect(study.activeRunId, isNull);
    });
  });
}
