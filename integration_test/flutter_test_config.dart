import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Picked up by `flutter test` for every test in this directory.
///
/// A tap (or drag) aimed at a widget it would not actually reach -- covered by
/// something else, off screen, or aimed with stale positions -- only prints a
/// warning by default and carries on, so the test fails later and far from the
/// cause. Making it fatal fails at the tap, with the hit-test result.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetController.hitTestWarningShouldBeFatal = true;
  await testMain();
}
