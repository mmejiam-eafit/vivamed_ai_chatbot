import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app's [ThemeMode] and persists it across launches (DT §10.5,
/// DL D-013). The app's first piece of state above the page level and its
/// first dependency beyond `flutter_svg` — kept deliberately small: no
/// state-management package, no repository, one [ChangeNotifier].
class ThemeController extends ChangeNotifier {
  ThemeController._(this._mode, this._prefs);

  static const _prefsKey = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Reads the persisted choice, defaulting to [ThemeMode.dark] if nothing
  /// is stored yet — the app opens dark regardless of the system setting
  /// (D-013), so a first launch has no override to read back.
  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => ThemeMode.dark,
    );
    return ThemeController._(mode, prefs);
  }

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    _prefs.setString(_prefsKey, mode.name);
  }
}

/// Makes the app's single [ThemeController] reachable from any descendant
/// (e.g. the Settings Appearance section) without prop-drilling a callback
/// down through every intermediate widget.
class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'No ThemeControllerScope found in context');
    return scope!.notifier!;
  }
}
