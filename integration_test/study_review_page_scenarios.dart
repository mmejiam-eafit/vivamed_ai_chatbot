import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/severity_dot.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

import 'fixtures/case_repository_fixture.dart';
import 'fixtures/conversation_repository_fixture.dart';
import 'fixtures/findings_repository_fixture.dart';
import 'fixtures/fixture_result.dart';
import 'fixtures/user_repository_fixture.dart';

/// Fixture-backed scenarios: success path and loading only. The error
/// branches are covered by `test/ui/pages/study_review_page_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, {List<Override> overrides = const []}) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      );

  // Three-zone tier so imageViewer/findingsPanel/chatPanel all render at
  // once instead of behind an unselected tab (see
  // study_review_page_test.dart's own "renders ChatPanel slot" comment).
  void setThreeZoneSize(WidgetTester tester) {
    tester.view.physicalSize =
        const Size(AppLayout.threePaneMinWidth * 1.1, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<Override> fixtureOverrides({
    required FixtureResult<List<ConversationItem>> conversations,
    required FixtureResult<List<ChatMessageItem>> messages,
    required FixtureResult<CaseDetail> caseDetail,
    required FixtureResult<List<FindingItem>> findings,
  }) =>
      [
        conversationRepositoryProvider.overrideWithValue(
          ConversationRepositoryFixture(
            getConversationsResult: conversations,
            getMessagesResult: messages,
          ),
        ),
        userRepositoryProvider.overrideWithValue(UserRepositoryFixture(
          getCurrentUserResult: const FixtureSuccess(UserProfile(
            name: 'Fixture User',
            role: 'Fixture Role',
            email: 'fixture@example.invalid',
            initials: 'FU',
          )),
        )),
        caseRepositoryProvider.overrideWithValue(
          CaseRepositoryFixture(getCaseDetailResult: caseDetail),
        ),
        findingsRepositoryProvider.overrideWithValue(
          FindingsRepositoryFixture(getFindingsResult: findings),
        ),
      ];

  testWidgets('success renders fixture case detail, findings, and messages',
      (tester) async {
    setThreeZoneSize(tester);
    await tester.pumpWidget(wrap(
      const StudyReviewPage(caseId: 'fixture-case'),
      overrides: fixtureOverrides(
        conversations: const FixtureSuccess([]),
        messages: const FixtureSuccess([
          ChatMessageItem(message: 'Fixture study message', isUser: false),
        ]),
        caseDetail: FixtureSuccess(CaseDetail(
          caseSummary: CaseSummary(
            id: 'fixture-case',
            title: 'Fixture Study',
            patient: 'Fixture Patient',
            modality: 'CXR',
            date: DateTime(2026, 1, 1),
            confidence: 0.9,
            severity: SeverityLevel.normal,
          ),
          imageUrl: 'https://example.invalid/fixture.png',
        )),
        findings: const FixtureSuccess([
          FindingItem(
              id: 'f1',
              name: 'Fixture Finding',
              severity: SeverityLevel.moderate),
        ]),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Fixture Finding'), findsOneWidget);
    expect(find.text('Fixture study message'), findsOneWidget);
  });

  testWidgets('while loading, shows loading indicators', (tester) async {
    setThreeZoneSize(tester);
    await tester.pumpWidget(wrap(
      const StudyReviewPage(caseId: 'fixture-case'),
      overrides: fixtureOverrides(
        conversations: const FixturePending(),
        messages: const FixturePending(),
        caseDetail: const FixturePending(),
        findings: const FixturePending(),
      ),
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsWidgets);
  });
}
