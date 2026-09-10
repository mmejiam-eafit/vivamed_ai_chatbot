import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
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
    return SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      selectedIndex: _selectedIndex,
      onSectionSelected: (i) => setState(() => _selectedIndex = i),
      sections: const [
        SettingsSection(title: 'Account', child: SizedBox()),
        SettingsSection(title: 'Display', child: SizedBox()),
        SettingsSection(title: 'About', child: SizedBox()),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'settings', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewSettingsPage() => const SettingsPage();
