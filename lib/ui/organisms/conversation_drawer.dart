import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

class ConversationDrawer extends StatelessWidget {
  const ConversationDrawer({
    super.key,
    required this.conversations,
    this.selectedId,
    this.onSelect,
    this.userInitials,
    this.userImageUrl,
    this.userName,
    this.onSettings,
    this.onMenuTap,
    this.isWide = false,
  });

  final List<ConversationItem> conversations;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final String? userInitials;
  final String? userImageUrl;
  final String? userName;
  final VoidCallback? onSettings;

  /// When provided, the bottom row opens the primary nav menu instead of
  /// going straight to Settings -- the expanded/ultrawide variant of this
  /// drawer, where the app bar (and its hamburger) is gone and this row is
  /// the menu's new home. Takes priority over [onSettings] when both are
  /// given, though in practice a caller passes exactly one.
  final VoidCallback? onMenuTap;

  /// True when this instance is rendered as a persistent sidebar
  /// (`drawerWide`, expanded/ultrawide) rather than a slide-over
  /// (`Scaffold.drawer`, compact/medium) -- picks `NavigationTokens
  /// .sideNavWidth` (240) over the slide-over's own `.drawerWidth` (280).
  /// The organism owns this choice since only organisms (not templates) may
  /// reference `NavigationTokens` -- the caller passes a plain bool, not a
  /// token.
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final showMenu = onMenuTap != null;
    // Drawer, not a bare Container: this is Flutter's own purpose-built
    // container for a Scaffold.drawer slot — it carries the standard
    // elevation/shape and a semantic drawer label for screen readers that a
    // plain Container never gets, for the same width/background this always
    // had.
    return Drawer(
      width: isWide ? NavigationTokens.sideNavWidth : NavigationTokens.drawerWidth,
      backgroundColor: NavigationTokens.drawerBackground(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const AppDivider(),
            Expanded(child: _buildConversationList(context)),
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: NavItem(
                icon: showMenu ? Icons.menu : Icons.settings_outlined,
                label: showMenu ? 'Menu' : 'Settings',
                onTap: showMenu ? onMenuTap : onSettings,
                // This drawer's background is surfaceBrandSecondary, not
                // AppNavBar's surface -- match the on-brand color the rest
                // of this drawer already uses (e.g. the conversation tiles'
                // unselected icon, above) instead of NavItem's old
                // bottomNav*-only default, which was tuned for AppNavBar's
                // light background. This row is never actually selected
                // today, but sideNavSelected (not bottomNavSelected) is the
                // semantically correct pair for a side-nav drawer either way.
                selectedColor: NavigationTokens.sideNavSelected(context),
                unselectedColor: context.colors.iconOnBrand,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AppAvatar(imageUrl: userImageUrl, initials: userInitials, radius: 20.0),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              userName ?? 'Radiologist',
              style: AppTypography.labelLg,
              color: context.colors.textOnBrand,
              // Was clamped to 1 line at a fixed width — no room to grow at
              // 200% text scale (DT §3.7).
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList(BuildContext context) {
    if (conversations.isEmpty) {
      return Center(
        child: AppText(
          'No conversations yet.',
          style: AppTypography.bodySm,
          color: context.colors.textOnBrand,
        ),
      );
    }
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final item = conversations[index];
        return _ConversationTile(
          item: item,
          isSelected: item.id == selectedId,
          onTap: () => onSelect?.call(item.id),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ConversationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      hoverColor: NavigationTokens.sideNavHoverColor(context),
      child: Container(
        color: isSelected ? colors.surfaceBrandSecondarySubdued : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            AppIcon(
              Icons.chat_bubble_outline,
              color: isSelected
                  ? NavigationTokens.bottomNavSelected(context)
                  : colors.iconOnBrand,
              size: 20.0,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    item.title,
                    style: AppTypography.labelMd,
                    color: colors.textOnBrand,
                    // Was clamped to 1 line inside a fixed-width drawer — no
                    // room to grow at 200% text scale (DT §3.7).
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  AppText(
                    item.subtitle,
                    style: AppTypography.caption,
                    color: colors.textMuted,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

const _previewConversations = [
  ConversationItem(id: '1', title: 'Chest CT — Patient A', subtitle: '2 hours ago'),
  ConversationItem(id: '2', title: 'Abdominal MRI — Patient B', subtitle: 'Yesterday'),
  ConversationItem(id: '3', title: 'Chest X-Ray — Patient C', subtitle: '2026-05-20'),
];

@Preview(name: 'with conversations', size: Size(280, 500), wrapper: previewWrapper)
Widget previewConversationDrawerFull() => const ConversationDrawer(
      conversations: _previewConversations,
      selectedId: '1',
      userInitials: 'DR',
      userName: 'Dr. Ramirez',
    );

@Preview(name: 'empty', size: Size(280, 300), wrapper: previewWrapper)
Widget previewConversationDrawerEmpty() => const ConversationDrawer(
      conversations: [],
      userInitials: 'DR',
      userName: 'Dr. Ramirez',
    );
