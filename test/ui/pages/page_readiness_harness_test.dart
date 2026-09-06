import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/templates/auth_template.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';
import 'package:radiologist_helper/ui/templates/onboarding_template.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

void main() {
  group('Page readiness harness', () {
    testWidgets('Chat page harness maps to ChatTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: _ChatPageHarness()),
      );

      expect(find.byType(ChatTemplate), findsOneWidget);
      expect(find.text('chat-ready'), findsOneWidget);
    });

    testWidgets('Study review page harness maps to StudyReviewTemplate',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: _StudyReviewPageHarness()),
      );

      expect(find.byType(StudyReviewTemplate), findsOneWidget);
      expect(find.text('study-ready'), findsOneWidget);
    });

    testWidgets('Settings page harness maps to SettingsTemplate',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: _SettingsPageHarness()),
      );

      expect(find.byType(SettingsTemplate), findsOneWidget);
      expect(find.text('settings-ready'), findsOneWidget);
    });

    testWidgets('Onboarding page harness maps to OnboardingTemplate',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: _OnboardingPageHarness()),
      );

      expect(find.byType(OnboardingTemplate), findsOneWidget);
      expect(find.text('onboarding-ready'), findsOneWidget);
    });

    testWidgets('Login page harness maps to AuthTemplate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: buildAppTheme(), home: _LoginPageHarness()),
      );

      expect(find.byType(AuthTemplate), findsOneWidget);
      expect(find.text('login-ready'), findsOneWidget);
    });
  });
}

class _ChatPageHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChatTemplate(
      appBar: AppBar(title: const Text('Chat')),
      chatPanel: const Text('chat-ready'),
      findingsPanel: const Text('findings-ready'),
    );
  }
}

class _StudyReviewPageHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StudyReviewTemplate(
      appBar: AppBar(title: const Text('Study Review')),
      imageViewer: const Text('image-ready'),
      findingsPanel: const Text('study-findings-ready'),
      chatPanel: const Text('study-ready'),
    );
  }
}

class _SettingsPageHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: const [Text('settings-ready')],
    );
  }
}

class _OnboardingPageHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const OnboardingTemplate(
      carousel: Text('onboarding-ready'),
    );
  }
}

class _LoginPageHarness extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AuthTemplate(formContent: Text('login-ready'));
  }
}
