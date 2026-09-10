import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeController', () {
    test('load() defaults to dark with no stored value', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();
      expect(controller.mode, ThemeMode.dark);
    });

    test('load() reads back a stored value', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final controller = await ThemeController.load();
      expect(controller.mode, ThemeMode.light);
    });

    test('setMode updates mode and notifies listeners', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setMode(ThemeMode.light);

      expect(controller.mode, ThemeMode.light);
      expect(notified, isTrue);
    });

    test('setMode persists the new value', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();

      controller.setMode(ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'system');
    });

    test('setMode is a no-op when the mode is unchanged', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await ThemeController.load();
      var notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.setMode(ThemeMode.dark);

      expect(notifyCount, 0);
    });
  });
}
