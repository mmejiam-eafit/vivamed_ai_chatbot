import 'package:flutter/material.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/login_page.dart';
import 'package:radiologist_helper/ui/pages/onboarding_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';

abstract final class Routes {
  static const String login = '/';
  static const String onboarding = '/onboarding';
  static const String chat = '/chat';
  static const String studyReview = '/study-review';
  static const String caseList = '/cases';
  static const String heatmapViewer = '/heatmap';
  static const String settings = '/settings';
}

class App extends StatelessWidget {
  const App({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: themeController,
      child: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) => MaterialApp(
          title: 'Radiologist Helper',
          theme: buildAppTheme(Brightness.light),
          darkTheme: buildAppTheme(Brightness.dark),
          themeMode: themeController.mode,
          debugShowCheckedModeBanner: false,
          initialRoute: Routes.login,
          routes: {
            Routes.login: (_) => const LoginPage(),
            Routes.onboarding: (_) => const OnboardingPage(),
            Routes.chat: (_) => const ChatPage(),
            // Placeholder caseId -- this named route (and passing real
            // arguments through it) goes away in the routing-cleanup chunk
            // of app_navigation_plan.md; nothing reaches it by name today.
            Routes.studyReview: (_) => const StudyReviewPage(caseId: 'case-1'),
            Routes.caseList: (_) => const CaseListPage(),
            Routes.heatmapViewer: (_) => const HeatmapViewerPage(),
            Routes.settings: (_) => const SettingsPage(),
          },
        ),
      ),
    );
  }
}
