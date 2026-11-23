import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/case_service.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';

class _FakeCaseRepository implements CaseRepository {
  String? lastSimilarCasesCaseId;

  @override
  Future<List<CaseSummary>> getCases() async => [];

  @override
  Future<CaseDetail> getCaseDetail(String caseId) async =>
      throw UnimplementedError();

  @override
  Future<SimilarCases> getSimilarCases(String caseId) async {
    lastSimilarCasesCaseId = caseId;
    return const SimilarCases(
      cases: [],
      imagesUsed: 1,
      imagesTotal: 1,
      imagesHeldBack: 0,
    );
  }
}

class _FakeFindingsRepository implements FindingsRepository {
  @override
  Future<List<FindingItem>> getFindings(String caseId) async => [];
}

/// Answers each worklist read with the next of [answers], repeating the last
/// one, and counts the reads. With [error] set, a read throws it instead.
class _ScriptedCaseRepository implements CaseRepository {
  _ScriptedCaseRepository(this.answers);

  final List<List<CaseSummary>> answers;
  Object? error;
  var reads = 0;

  @override
  Future<List<CaseSummary>> getCases() async {
    reads++;
    if (error case final error?) throw error;
    return answers[(reads - 1).clamp(0, answers.length - 1)];
  }

  @override
  Future<CaseDetail> getCaseDetail(String caseId) async =>
      throw UnimplementedError();

  @override
  Future<SimilarCases> getSimilarCases(String caseId) async =>
      throw UnimplementedError();
}

List<CaseSummary> _studies(StudyStatus status) => [
      CaseSummary(
        id: 'case-1',
        title: 'Chest X-Ray',
        patient: 'Anonymous 1',
        modality: 'CXR',
        date: DateTime(2026, 11, 1),
        confidence: 0.9,
        severity: SeverityLevel.mild,
        status: status,
      ),
    ];

void main() {
  test('getSimilarCases passes the case id straight through', () async {
    final fakeCaseRepository = _FakeCaseRepository();
    final service = CaseService(fakeCaseRepository, _FakeFindingsRepository());

    await service.getSimilarCases('case-2');

    expect(fakeCaseRepository.lastSimilarCasesCaseId, 'case-2');
  });

  // testWidgets for its fake clock: pump(duration) moves time on, and a
  // timer still pending when a test ends fails it.
  group('CaseService.watchCases', () {
    CaseService service(CaseRepository repository) => CaseService(
          repository,
          _FakeFindingsRepository(),
          pollInterval: const Duration(seconds: 5),
        );

    testWidgets('reads at once, and never again while nothing is in progress',
        (tester) async {
      final repository =
          _ScriptedCaseRepository([_studies(StudyStatus.ready)]);
      final events = <List<CaseSummary>>[];
      final subscription = service(repository).watchCases().listen(events.add);

      await tester.pump();
      expect(repository.reads, 1);
      expect(events, hasLength(1));

      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 1);
      // Not awaited: with no onCancel future, cancel() answers with a
      // future of the root zone, which the fake clock never completes.
      subscription.cancel();
    });

    testWidgets('reads every interval while a study is in progress, and stops '
        'once none is', (tester) async {
      final repository = _ScriptedCaseRepository([
        _studies(StudyStatus.queued),
        _studies(StudyStatus.processing),
        _studies(StudyStatus.ready),
      ]);
      final statuses = <StudyStatus>[];
      final subscription = service(repository)
          .watchCases()
          .listen((cases) => statuses.add(cases.single.status));

      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(statuses, [
        StudyStatus.queued,
        StudyStatus.processing,
        StudyStatus.ready,
      ]);

      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 3);
      subscription.cancel();
    });

    testWidgets('pausing stops the reads, and resuming reads at once',
        (tester) async {
      final repository =
          _ScriptedCaseRepository([_studies(StudyStatus.processing)]);
      final subscription = service(repository).watchCases().listen((_) {});
      await tester.pump();
      expect(repository.reads, 1);

      subscription.pause();
      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 1);

      subscription.resume();
      await tester.pump();
      expect(repository.reads, 2);
      subscription.cancel();
    });

    testWidgets('cancelling leaves no read waiting', (tester) async {
      final repository =
          _ScriptedCaseRepository([_studies(StudyStatus.processing)]);
      final subscription = service(repository).watchCases().listen((_) {});
      await tester.pump();

      subscription.cancel();
      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 1);
    });

    testWidgets('a failed read is passed on and ends the reading',
        (tester) async {
      final repository =
          _ScriptedCaseRepository([_studies(StudyStatus.processing)])
            ..error = Exception('offline');
      Object? received;
      final subscription = service(repository)
          .watchCases()
          .listen((_) {}, onError: (Object error) => received = error);

      await tester.pump();
      expect(received, isA<Exception>());

      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 1);
      subscription.cancel();
    });
  });

  group('worklistProvider', () {
    testWidgets('stops reading while its only listener is paused, and reads '
        'at once when it resumes', (tester) async {
      final repository =
          _ScriptedCaseRepository([_studies(StudyStatus.processing)]);
      final container = ProviderContainer(overrides: [
        caseRepositoryProvider.overrideWithValue(repository),
      ]);
      final subscription = container.listen(worklistProvider, (_, _) {});
      await tester.pump();
      expect(repository.reads, 1);
      expect(container.read(worklistProvider).value, hasLength(1));

      // What a Consumer does when its route is covered (TickerMode off).
      subscription.pause();
      await tester.pump(const Duration(seconds: 30));
      expect(repository.reads, 1);

      subscription.resume();
      await tester.pump();
      expect(repository.reads, 2);

      // Disposed here, not in a tear-down: the fake clock checks for pending
      // timers as soon as the body ends.
      container.dispose();
    });
  });
}
