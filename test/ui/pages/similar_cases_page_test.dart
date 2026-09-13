import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/organisms/study_info_card.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/case_list_template.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  group('SimilarCasesPage', () {
    testWidgets('renders CaseListTemplate', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.byType(CaseListTemplate), findsOneWidget);
    });

    testWidgets('renders Similar Cases in app bar', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('Similar Cases'), findsOneWidget);
    });

    testWidgets('renders a pluralized count header', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('3 similar cases found'), findsOneWidget);
    });

    testWidgets('excludes the given case from the results', (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      expect(find.text('Chest X-Ray'), findsNothing);
      expect(find.byType(StudyInfoCard), findsNWidgets(3));
    });

    testWidgets('tapping a result opens Study Review for that case',
        (tester) async {
      await tester.pumpWidget(wrap(const SimilarCasesPage(caseId: 'case-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Abdominal CT'));
      await tester.pumpAndSettle();

      final page =
          tester.widget<StudyReviewPage>(find.byType(StudyReviewPage));
      expect(page.caseId, 'case-2');
    });
  });
}
