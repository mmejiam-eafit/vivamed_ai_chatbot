import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/theme_mode_selector.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerScope.of(context);
    return SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      selectedIndex: _selectedIndex,
      onSectionSelected: (i) => setState(() => _selectedIndex = i),
      sections: [
        const SettingsSection(title: 'Account', child: SizedBox()),
        SettingsSection(
          title: 'Appearance',
          // No extra ListenableBuilder needed: reading the scope above via
          // .of(context) already subscribes this whole build() to
          // ThemeController's notifications (InheritedNotifier's purpose).
          child: ThemeModeSelector(
            selected: themeController.mode,
            onChanged: themeController.setMode,
          ),
        ),
        const SettingsSection(title: 'About', child: SizedBox()),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'settings', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewSettingsPage() => const SettingsPage();
