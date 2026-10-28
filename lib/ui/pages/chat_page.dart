import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/primary_destinations.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/study_review_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _chatController = TextEditingController();

  /// Null until the radiologist picks one in the drawer -- then the default
  /// (the first conversation) is what's shown.
  String? _selectedConversationId;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage(String conversationId) {
    final accepted = ref
        .read(messagesProvider(conversationId).notifier)
        .send(_chatController.text);
    // A refused send (empty, history still loading, a reply still streaming)
    // keeps what was typed.
    if (accepted) _chatController.clear();
  }

  static const _destination = 1;

  Widget _navBar(BuildContext context) => AppNavBar(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: ref.watch(pendingReviewCountProvider),
      );

  Widget _primaryNavDrawer(BuildContext context) => PrimaryNavDrawer(
        selectedIndex: _destination,
        onDestinationSelected: (i) =>
            openPrimaryDestination(context, i, current: _destination),
        pendingReviewCount: ref.watch(pendingReviewCountProvider),
      );

  Widget _conversationDrawer(
    BuildContext context,
    AsyncValue<List<ConversationItem>> conversationsAsync,
    String? conversationId,
    UserProfile? user,
  ) {
    if (conversationsAsync.hasError) {
      return Drawer(
        child: Center(
          child: AppText(
            'Could not load conversations: ${conversationsAsync.error}',
          ),
        ),
      );
    }
    return ConversationDrawer(
      conversations: conversationsAsync.value ?? const [],
      selectedId: conversationId,
      onSelect: (id) => setState(() => _selectedConversationId = id),
      userName: user?.name,
      userInitials: user?.initials,
      onSettings: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      ),
    );
  }

  /// Expanded/ultrawide variant of [_conversationDrawer] -- same data, but
  /// its bottom row opens the primary nav menu instead of Settings directly
  /// (there's no app bar at that tier to host a hamburger in anymore).
  /// Builder-wrapped so Scaffold.of(context) resolves to the Scaffold this
  /// ends up inside once ChatTemplate places it, not this page's own
  /// context, which sits above it -- the same technique chat_template.dart's
  /// own _buildRail already uses for CollapsedNavRail's onMenuTap.
  Widget _conversationDrawerWide(
    BuildContext context,
    AsyncValue<List<ConversationItem>> conversationsAsync,
    String? conversationId,
    UserProfile? user,
  ) {
    if (conversationsAsync.hasError) {
      return Drawer(
        child: Center(
          child: AppText(
            'Could not load conversations: ${conversationsAsync.error}',
          ),
        ),
      );
    }
    return Builder(
      builder: (context) => ConversationDrawer(
        conversations: conversationsAsync.value ?? const [],
        selectedId: conversationId,
        onSelect: (id) => setState(() => _selectedConversationId = id),
        userName: user?.name,
        userInitials: user?.initials,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        isWide: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Chat'));
    final conversationsAsync = ref.watch(conversationsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final conversations = conversationsAsync.value ?? const [];
    // Null exactly while conversations haven't loaded yet -- can't pick a
    // default (or watch messagesProvider, a family that needs a real id)
    // before then. Not a new state: this is the same window ConversationDrawer
    // already renders as "nothing selected" via its nullable selectedId.
    final conversationId = _selectedConversationId ??
        (conversations.isEmpty ? null : conversations.first.id);
    final messagesAsync =
        conversationId == null ? null : ref.watch(messagesProvider(conversationId));

    Widget messageListSection() {
      if (conversationsAsync.hasError) {
        return Center(
          child: AppText('Could not load conversations: ${conversationsAsync.error}'),
        );
      }
      if (conversationsAsync.isLoading || messagesAsync == null) {
        return const Center(child: AppLoadingIndicator());
      }
      return messagesAsync.when(
        data: (messages) => ChatMessageList(
          messages: messages,
          onCaseReferenceTap: (caseId) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudyReviewPage(
                caseId: caseId,
                conversationId: conversationId,
              ),
            ),
          ),
        ),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stackTrace) =>
            Center(child: AppText('Could not load messages: $error')),
      );
    }

    return ChatTemplate(
      appBar: appBar,
      // Routed through the template (rather than an early-return Scaffold)
      // so its own tier-aware chrome -- appBar hidden, primaryNavDrawer via
      // drawerWide -- still applies while providers are resolving, not just
      // once they've loaded.
      chatPanel: ChatPanel(
        messageList: messageListSection(),
        controller: _chatController,
        onSubmit: conversationId == null ? () {} : () => _sendMessage(conversationId),
        isLoading: messagesAsync?.value
                ?.any((m) => m.status == ChatMessageStatus.streaming) ??
            false,
      ),
      drawer: _conversationDrawer(
        context,
        conversationsAsync,
        conversationId,
        userAsync.value,
      ),
      drawerWide: _conversationDrawerWide(
        context,
        conversationsAsync,
        conversationId,
        userAsync.value,
      ),
      navBar: _navBar(context),
      primaryNavDrawer: _primaryNavDrawer(context),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewChatPageWide() => const ChatPage();

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewChatPageNarrow() => const ChatPage();
