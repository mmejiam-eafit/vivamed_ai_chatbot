import 'package:flutter/material.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/home_hub_page.dart';
import 'package:radiologist_helper/ui/pages/login_page.dart';
import 'package:radiologist_helper/ui/pages/onboarding_page.dart';

/// The only argument-free, static entry points. Every other screen takes
/// real constructor arguments and is reached by a direct
/// `Navigator.push(MaterialPageRoute(builder: ...))` from Home Hub or from
/// each other -- one consistent mechanism everywhere else.
abstract final class Routes {
  static const String login = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
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
            Routes.home: (_) => const HomeHubPage(),
          },
        ),
      ),
    );
  }
}
