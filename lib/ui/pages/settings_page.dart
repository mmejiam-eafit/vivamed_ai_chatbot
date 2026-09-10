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
Widget previewSettingsPage() => const _SettingsPagePreview();

/// SettingsPage reads ThemeControllerScope.of(context) directly, which the
/// shared preview wrappers don't provide. ThemeController.load() is async
/// and a @Preview function must return a Widget synchronously, so this
/// awaits it once (via FutureBuilder, not a second construction path on
/// the controller itself) rather than skipping the preview.
class _SettingsPagePreview extends StatefulWidget {
  const _SettingsPagePreview();

  @override
  State<_SettingsPagePreview> createState() => _SettingsPagePreviewState();
}

class _SettingsPagePreviewState extends State<_SettingsPagePreview> {
  late final Future<ThemeController> _controller = ThemeController.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeController>(
      future: _controller,
      builder: (context, snapshot) {
        final controller = snapshot.data;
        if (controller == null) return const SizedBox();
        return ThemeControllerScope(
          controller: controller,
          child: const SettingsPage(),
        );
      },
    );
  }
}
