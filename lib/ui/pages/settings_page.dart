import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/mocks/settings_mocks.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/theme_controller.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/metadata_field.dart';
import 'package:radiologist_helper/ui/molecules/theme_mode_selector.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/templates/settings_template.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _selectedIndex = 0;

  Widget _navBar(BuildContext context) => AppNavBar(
        selectedIndex: 3,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst);
            case 1:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CaseListPage()),
              );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeControllerScope.of(context);
    final userAsync = ref.watch(currentUserProvider);
    return SettingsTemplate(
      appBar: AppBar(title: const Text('Settings')),
      selectedIndex: _selectedIndex,
      onSectionSelected: (i) => setState(() => _selectedIndex = i),
      navBar: _navBar(context),
      sections: [
        SettingsSection(
          title: 'Account',
          child: userAsync.when(
            data: (user) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MetadataField(label: 'Name', value: user.name),
                MetadataField(label: 'Role', value: user.role),
                MetadataField(label: 'Email', value: user.email),
              ],
            ),
            loading: () => const AppLoadingIndicator(),
            error: (error, stackTrace) =>
                AppText('Could not load account: $error'),
          ),
        ),
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
        const SettingsSection(
          title: 'About',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetadataField(label: 'Version', value: mockAppVersion),
              MetadataField(label: 'Build', value: mockAppBuild),
            ],
          ),
        ),
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
