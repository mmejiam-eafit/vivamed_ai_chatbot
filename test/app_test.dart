import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ThemeController> controllerWith(ThemeMode mode) async {
    SharedPreferences.setMockInitialValues({'theme_mode': mode.name});
    return ThemeController.load();
  }

  group('App', () {
    testWidgets('resolves MaterialApp.themeMode from the controller',
        (tester) async {
      final controller = await controllerWith(ThemeMode.light);
      await tester.pumpWidget(App(themeController: controller));

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);
    });

    testWidgets('changing the controller updates MaterialApp.themeMode',
        (tester) async {
      final controller = await controllerWith(ThemeMode.dark);
      await tester.pumpWidget(App(themeController: controller));
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );

      controller.setMode(ThemeMode.light);
      await tester.pump();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );
    });
  });
}
