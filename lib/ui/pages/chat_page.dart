import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/app_nav_bar.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
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

  Future<void> _sendMessage(String conversationId) async {
    final text = _chatController.text;
    if (text.isEmpty) return;
    _chatController.clear();
    await ref.read(chatServiceProvider).sendMessage(conversationId, text);
    ref.invalidate(messagesProvider(conversationId));
  }

  Widget _navBar(BuildContext context) => AppNavBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst);
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CaseListPage()),
              );
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Chat'));
    final conversationsAsync = ref.watch(conversationsProvider);
    final userAsync = ref.watch(currentUserProvider);

    // The default conversation can't be picked until the list has loaded,
    // so this gates on it before messagesProvider is even read.
    if (conversationsAsync.isLoading || userAsync.isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: AppLoadingIndicator()),
        bottomNavigationBar: _navBar(context),
      );
    }

    final conversations = conversationsAsync.value ?? const [];
    final conversationId = _selectedConversationId ?? conversations.first.id;
    final messagesAsync = ref.watch(messagesProvider(conversationId));

    if (messagesAsync.isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: AppLoadingIndicator()),
        bottomNavigationBar: _navBar(context),
      );
    }

    return ChatTemplate(
      appBar: appBar,
      chatPanel: ChatPanel(
        messageList: ChatMessageList(
          messages: messagesAsync.value ?? const [],
          onCaseReferenceTap: (caseId) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => StudyReviewPage(
                caseId: caseId,
                conversationId: conversationId,
              ),
            ),
          ),
        ),
        controller: _chatController,
        onSubmit: () => _sendMessage(conversationId),
      ),
      drawer: ConversationDrawer(
        conversations: conversations,
        selectedId: conversationId,
        onSelect: (id) => setState(() => _selectedConversationId = id),
        userName: userAsync.value?.name,
        userInitials: userAsync.value?.initials,
        onSettings: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        ),
      ),
      navBar: _navBar(context),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewChatPageWide() => const ChatPage();

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewChatPageNarrow() => const ChatPage();
