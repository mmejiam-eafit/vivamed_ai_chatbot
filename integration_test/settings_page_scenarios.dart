import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fixtures/fixture_result.dart';
import 'fixtures/user_repository_fixture.dart';

/// Fixture-backed scenarios for Settings' "Account" section -- overrides
/// `userRepositoryProvider` directly (confirmed: `currentUserProvider`
/// resolves through `UserRepository`, not `AuthRepository`).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> wrap(Widget child,
      {List<Override> overrides = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    return ProviderScope(
      overrides: overrides,
      child: ThemeControllerScope(
        controller: controller,
        child: MaterialApp(theme: buildAppTheme(), home: child),
      ),
    );
  }

  testWidgets('success renders the fixture profile fields', (tester) async {
    final fixture = UserRepositoryFixture(
      getCurrentUserResult: const FixtureSuccess(UserProfile(
        name: 'Dr. Fixture Name',
        role: 'Fixture Role',
        email: 'fixture@example.invalid',
        initials: 'FN',
      )),
    );
    await tester.pumpWidget(await wrap(
      const SettingsPage(),
      overrides: [userRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Fixture Name'), findsOneWidget);
    expect(find.text('Fixture Role'), findsOneWidget);
    expect(find.text('fixture@example.invalid'), findsOneWidget);
  });

  testWidgets('failure shows the error text', (tester) async {
    final fixture = UserRepositoryFixture(
      getCurrentUserResult: const FixtureFailure('fixture account failure'),
    );
    await tester.pumpWidget(await wrap(
      const SettingsPage(),
      overrides: [userRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not load account'), findsOneWidget);
  });

  testWidgets('while loading, shows the loading indicator', (tester) async {
    final fixture = UserRepositoryFixture(
      getCurrentUserResult: const FixturePending(),
    );
    await tester.pumpWidget(await wrap(
      const SettingsPage(),
      overrides: [userRepositoryProvider.overrideWithValue(fixture)],
    ));
    await tester.pump();

    expect(find.byType(AppLoadingIndicator), findsOneWidget);
  });
}
