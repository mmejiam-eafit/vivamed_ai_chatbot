import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/atoms/app_avatar.dart';
import 'package:radiologist_helper/ui/atoms/app_divider.dart';
import 'package:radiologist_helper/ui/atoms/app_icon.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/molecules/nav_item.dart';

class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

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
  });

  final List<ConversationItem> conversations;
  final String? selectedId;
  final ValueChanged<String>? onSelect;
  final String? userInitials;
  final String? userImageUrl;
  final String? userName;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: NavigationTokens.drawerWidth,
      color: NavigationTokens.drawerBackground(context),
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
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onSettings,
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
