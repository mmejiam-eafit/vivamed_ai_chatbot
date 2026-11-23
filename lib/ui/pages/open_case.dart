import 'package:flutter/material.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/ui/pages/processing_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

/// Opens [study] where its state is (DL D-024), from any list of studies:
///
/// - a run under way: the Processing page, following that run;
/// - failed, with failed items still open: the Processing page, listing
///   them;
/// - anything else, including a failed study whose failures were all
///   discarded: Study Review.
///
/// Not a widget: page-level navigation shared by the Studies and Similar
/// Cases pages, which are the only level allowed to navigate.
void openCase(BuildContext context, CaseSummary study) {
  final runId = study.activeRunId;
  final Widget page;
  if (runId != null) {
    page = ProcessingPage(caseId: study.id, runId: runId);
  } else if (study.status == StudyStatus.failed && study.openFailures > 0) {
    page = ProcessingPage(caseId: study.id);
  } else {
    page = StudyReviewPage(caseId: study.id);
  }
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
