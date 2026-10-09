import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

/// Golden-image regression coverage for the nav-shell chrome that moved out
/// of the templates and into their organisms (a template may only use
/// `surfacePage` and `AppSpacing`): `ConversationDrawer`'s rendered width as
/// `drawerWide`, and the Settings divider's footprint.
/// Goldens were captured from the pre-fix code first (`--update-goldens`),
/// specifically so a passing re-run after the fix proves pixel parity, not
/// just "looks right" by eye.
void main() {
  void setSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  void setWideSize(WidgetTester tester) =>
      setSize(tester, const Size(1200, 900));

  Widget wrap(Widget child) => MaterialApp(theme: buildAppTheme(), home: child);

  const conversations = [
    ConversationItem(
      id: '1',
      title: 'Chest CT — Patient A',
      subtitle: '2 hours ago',
    ),
    ConversationItem(
      id: '2',
      title: 'Abdominal MRI — Patient B',
      subtitle: 'Yesterday',
    ),
  ];

  testWidgets('ChatTemplate wide layout with drawerWide matches golden', (
    tester,
  ) async {
    setWideSize(tester);
    await tester.pumpWidget(
      wrap(
        ChatTemplate(
          appBar: AppBar(title: const Text('Chat')),
          chatPanel: const ColoredBox(color: Color(0xFF3F51B5)),
          drawerWide: ConversationDrawer(
            conversations: conversations,
            isWide: true,
            onMenuTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(ChatTemplate),
      matchesGoldenFile('goldens/chat_template_wide.png'),
    );
  });

  testWidgets(
    'StudyReviewTemplate three-zone layout with drawerWide matches golden',
    (tester) async {
      setWideSize(tester);
      await tester.pumpWidget(
        wrap(
          StudyReviewTemplate(
            appBar: AppBar(title: const Text('Study Review')),
            imageViewer: const ColoredBox(color: Color(0xFF455A64)),
            findingsPanel: const ColoredBox(color: Color(0xFF00695C)),
            chatPanel: const ColoredBox(color: Color(0xFF3F51B5)),
            drawerWide: ConversationDrawer(
              conversations: conversations,
              isWide: true,
              onMenuTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StudyReviewTemplate),
        matchesGoldenFile('goldens/study_review_template_wide.png'),
      );
    },
  );

  testWidgets(
    'StudyReviewTemplate ultrawide layout with drawerWide matches golden',
    (tester) async {
      // Above ultrawideMinWidth the viewer and findings sit side by side (3 : 2)
      // instead of stacked -- the one layout that only exists at this width
      // and nothing else exercised it.
      setSize(tester, const Size(1920, 1080));
      await tester.pumpWidget(
        wrap(
          StudyReviewTemplate(
            appBar: AppBar(title: const Text('Study Review')),
            imageViewer: const ColoredBox(color: Color(0xFF455A64)),
            findingsPanel: const ColoredBox(color: Color(0xFF00695C)),
            chatPanel: const ColoredBox(color: Color(0xFF3F51B5)),
            drawerWide: ConversationDrawer(
              conversations: conversations,
              isWide: true,
              onMenuTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(StudyReviewTemplate),
        matchesGoldenFile('goldens/study_review_template_ultrawide.png'),
      );
    },
  );

  testWidgets('SettingsTemplate two-column layout matches golden', (
    tester,
  ) async {
    setWideSize(tester);
    await tester.pumpWidget(
      wrap(
        SettingsTemplate(
          appBar: AppBar(title: const Text('Settings')),
          sections: const [
            SettingsSection(
              title: 'Account',
              child: MetadataField(label: 'Name', value: 'Dr. A. Ramírez'),
            ),
            SettingsSection(
              title: 'Appearance',
              child: MetadataField(label: 'Theme', value: 'Dark'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SettingsTemplate),
      matchesGoldenFile('goldens/settings_template_wide.png'),
    );
  });
}
