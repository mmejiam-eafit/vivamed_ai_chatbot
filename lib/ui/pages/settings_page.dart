import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      sections: const [
        AppText('Account'),
        AppText('Display'),
        AppText('About'),
      ],
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'settings', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewSettingsPage() => const SettingsPage();
