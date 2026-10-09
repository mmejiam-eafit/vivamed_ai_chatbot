import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/hub_action_card.dart';
import 'package:radiologist_helper/ui/organisms/menu_rail.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/upload_page.dart';
import 'package:radiologist_helper/ui/templates/home_hub_template.dart';

/// The navigation root a radiologist lands on after signing in — two ways to
/// reach a study (upload a new one or browse existing ones), plus standalone
/// Chat and Settings. No data of its own to load, unlike the pages it leads
/// to.
class HomeHubPage extends StatelessWidget {
  const HomeHubPage({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  // Home Hub is itself the "Home" destination -- case 0 is deliberately
  // omitted, the same "own destination is a no-op" pattern every other
  // primary destination page already uses (Case List omits case 2,
  // Settings omits case 3, etc.).
  void _onPrimaryDestinationSelected(BuildContext context, int i) {
    switch (i) {
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      case 2:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CaseListPage()),
        );
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
    }
  }

  Widget _primaryNavDrawer(BuildContext context) => PrimaryNavDrawer(
        selectedIndex: 0,
        onDestinationSelected: (i) => _onPrimaryDestinationSelected(context, i),
      );

  /// Builder-wrapped so Scaffold.of(context) resolves to the Scaffold this
  /// ends up inside once HomeHubTemplate places it, not this page's own
  /// context, which sits above it.
  Widget _menuRail(BuildContext context) => Builder(
        builder: (context) => MenuRail(
          onMenuTap: () => Scaffold.of(context).openDrawer(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return HomeHubTemplate(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _push(context, const SettingsPage()),
          ),
        ],
      ),
      uploadCard: HubActionCard(
        icon: Icons.upload_file,
        title: 'Upload a study',
        description: 'Analyze a new DICOM study',
        onTap: () => _push(context, const UploadPage()),
      ),
      viewStudiesCard: HubActionCard(
        icon: Icons.folder_outlined,
        title: 'View studies',
        description: 'Browse existing studies',
        onTap: () => _push(context, const CaseListPage()),
      ),
      chatCard: HubActionCard(
        icon: Icons.chat_bubble_outline,
        title: 'Chat',
        description: 'Ask about any case',
        onTap: () => _push(context, const ChatPage()),
      ),
      primaryNavDrawer: _primaryNavDrawer(context),
      menuRail: _menuRail(context),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewHomeHubPageNarrow() => const HomeHubPage();

@Preview(name: 'wide', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewHomeHubPageWide() => const HomeHubPage();
