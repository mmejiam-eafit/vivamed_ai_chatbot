import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_flow_compact_medium_scenarios.dart' as app_flow_compact_medium;
import 'app_flow_scenarios.dart' as app_flow;
import 'case_list_page_scenarios.dart' as case_list_page;
import 'chat_page_scenarios.dart' as chat_page;
import 'heatmap_viewer_page_scenarios.dart' as heatmap_viewer_page;
import 'settings_page_scenarios.dart' as settings_page;
import 'similar_cases_page_scenarios.dart' as similar_cases_page;
import 'study_review_page_scenarios.dart' as study_review_page;
import 'upload_page_scenarios.dart' as upload_page;
import 'visual_regression_scenarios.dart' as visual_regression;

/// The one and only integration entrypoint: `flutter test integration_test
/// -d linux` launches the app exactly once and runs every scenario in it.
///
/// This is deliberate, not a style choice. The Flutter tool's desktop device
/// reuses one log reader across launches and closes it when the first app
/// exits, so any *second* launch in a run fails with "Unable to start the app
/// on the device" (flutter/flutter#135673). Keeping every scenario behind a
/// single entrypoint makes the suite independent of how many scenario files
/// exist. That is also why scenario files are named `*_scenarios.dart`: a
/// directory run launches every `*_test.dart` it finds, so this must remain
/// the only one. `test/integration_entrypoint_test.dart` enforces that and
/// fails if a scenario file is missing from the list below.
///
/// Adding a scenario: create `<name>_scenarios.dart` with its own `main()`,
/// then import it above and add a `group` below.
///
/// Scenarios share one process, so process-wide state is shared too.
/// On desktop `app_flow` goes first on purpose: it relies on real on-disk
/// shared_preferences, while `settings_page` calls
/// `SharedPreferences.setMockInitialValues`, which swaps in an in-memory fake
/// for the rest of the process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Which scenarios run depends on where: a phone or tablet runs only the
  // compact/medium journeys (on the device's own screen -- see that file),
  // and desktop runs everything else, whose layouts are pinned to wide sizes.
  // The page scenarios and goldens pin sizes and are desktop-only.
  if (Platform.isAndroid || Platform.isIOS) {
    group('app_flow_compact_medium', app_flow_compact_medium.main);
    return;
  }

  group('app_flow', app_flow.main);
  group('case_list_page', case_list_page.main);
  group('chat_page', chat_page.main);
  group('heatmap_viewer_page', heatmap_viewer_page.main);
  group('settings_page', settings_page.main);
  group('similar_cases_page', similar_cases_page.main);
  group('study_review_page', study_review_page.main);
  group('upload_page', upload_page.main);
  group('visual_regression', visual_regression.main);
}
