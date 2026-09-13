import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingRepository {
  Future<bool> hasCompletedOnboarding();
  Future<void> markCompleted();
}

/// Real device storage, not a `Mock*` -- there's no future "real backend" to
/// swap in later, the same reasoning `ThemeController` already applies to
/// this same package.
class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const _prefsKey = 'has_completed_onboarding';

  @override
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  @override
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }
}
