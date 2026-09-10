import 'package:flutter/material.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = await ThemeController.load();
  runApp(App(themeController: themeController));
}
