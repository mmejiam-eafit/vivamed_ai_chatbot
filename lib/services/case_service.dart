import 'dart:async';

import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';

class CaseService {
  CaseService(
    this._caseRepository,
    this._findingsRepository, {
    this.pollInterval = const Duration(seconds: 5),
  });

  final CaseRepository _caseRepository;
  final FindingsRepository _findingsRepository;

  /// How long the worklist waits between two reads while a study is in
  /// progress: the interval the backend accepted for `GET /cases`.
  final Duration pollInterval;

  Future<List<CaseSummary>> getCases() => _caseRepository.getCases();

  /// The worklist, read again every [pollInterval] while any study is queued
  /// or processing, and not at all once none is: nothing else changes a
  /// status without someone acting on the study. The backend has no way to
  /// push a status to the app, so following one means asking.
  ///
  /// Pausing the stream stops the reads, and resuming reads at once, so a
  /// list shown again is never older than one read. Riverpod pauses it while
  /// no visible widget watches it, which keeps the reads to the backend's
  /// condition: only while the page is on screen.
  ///
  /// A failed read is passed on and ends the reading; whoever listens decides
  /// whether to listen again (Riverpod retries the provider with backoff).
  Stream<List<CaseSummary>> watchCases() {
    late final StreamController<List<CaseSummary>> controller;
    Timer? next;
    var reading = false;
    var cancelled = false;

    void stopWaiting() {
      next?.cancel();
      next = null;
    }

    Future<void> read() async {
      stopWaiting();
      // A read already under way answers for this one too.
      if (reading) return;
      reading = true;
      try {
        final cases = await _caseRepository.getCases();
        if (cancelled) return;
        controller.add(cases);
        if (!controller.isPaused && cases.any((c) => c.status.inProgress)) {
          next = Timer(pollInterval, read);
        }
      } catch (error, stackTrace) {
        if (!cancelled) controller.addError(error, stackTrace);
      } finally {
        reading = false;
      }
    }

    controller = StreamController<List<CaseSummary>>(
      onListen: read,
      onPause: stopWaiting,
      onResume: read,
      onCancel: () {
        cancelled = true;
        stopWaiting();
      },
    );
    return controller.stream;
  }

  /// The actual transformation this layer exists for: combines the case
  /// endpoint and the findings endpoint into what a study review screen
  /// needs in one call.
  Future<({CaseDetail detail, List<FindingItem> findings})> getCaseDetail(
    String caseId,
  ) async {
    final detail = await _caseRepository.getCaseDetail(caseId);
    final findings = await _findingsRepository.getFindings(caseId);
    return (detail: detail, findings: findings);
  }

  Future<SimilarCases> getSimilarCases(String caseId) =>
      _caseRepository.getSimilarCases(caseId);
}
