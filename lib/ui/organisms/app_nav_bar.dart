import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: NavigationTokens.bottomNavBackground,
        border: Border(top: BorderSide(color: AppColors.borderSubdued)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: selectedIndex == 0 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                label: 'Chat',
                isSelected: selectedIndex == 0,
                onTap: () => onDestinationSelected(0),
              ),
              NavItem(
                icon: selectedIndex == 1 ? Icons.folder : Icons.folder_outlined,
                label: 'Studies',
                isSelected: selectedIndex == 1,
                onTap: () => onDestinationSelected(1),
              ),
              NavItem(
                icon: selectedIndex == 2 ? Icons.settings : Icons.settings_outlined,
                label: 'Settings',
                isSelected: selectedIndex == 2,
                onTap: () => onDestinationSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'chat selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarChat() => AppNavBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
    );

@Preview(name: 'studies selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarStudies() => AppNavBar(
      selectedIndex: 1,
      onDestinationSelected: (_) {},
    );

@Preview(name: 'settings selected', size: Size(390, 72), wrapper: previewWrapper)
Widget previewAppNavBarSettings() => AppNavBar(
      selectedIndex: 2,
      onDestinationSelected: (_) {},
    );
