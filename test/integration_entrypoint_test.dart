import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the single-entrypoint layout described in
/// `integration_test/app_test.dart`: a directory run launches every
/// `*_test.dart` it finds, and a second app launch in one run fails on the
/// Flutter tool's desktop device (flutter/flutter#135673).
void main() {
  final dir = Directory('integration_test');

  test('app_test.dart is the only *_test.dart under integration_test/', () {
    final stray = dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('_test.dart') && !p.endsWith('/app_test.dart'))
        .toList();

    expect(
      stray,
      isEmpty,
      reason: 'Each *_test.dart is launched as its own app run, and a second '
          'launch fails. Rename to <name>_scenarios.dart and register it in '
          'integration_test/app_test.dart instead.',
    );
  });

  test('every *_scenarios.dart is registered in app_test.dart', () {
    final entrypoint = File('integration_test/app_test.dart').readAsStringSync();
    final unregistered = dir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((name) => name.endsWith('_scenarios.dart'))
        .where((name) => !entrypoint.contains("import '$name'"))
        .toList();

    expect(
      unregistered,
      isEmpty,
      reason: 'Not run by `flutter test integration_test`. Import each in '
          'integration_test/app_test.dart and add a group for it.',
    );
  });
}
