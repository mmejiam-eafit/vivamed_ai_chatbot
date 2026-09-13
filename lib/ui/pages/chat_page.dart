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
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

// Neither takes a case/conversation parameter yet -- no navigation means
// nothing selects one. The later flow-wiring pass is what makes these vary.
const _conversationId = 'conv-1';
const _caseId = 'case-1';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text;
    if (text.isEmpty) return;
    _chatController.clear();
    await ref.read(chatServiceProvider).sendMessage(_conversationId, text);
    ref.invalidate(messagesProvider(_conversationId));
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
    final messagesAsync = ref.watch(messagesProvider(_conversationId));
    final caseDetailAsync = ref.watch(caseDetailProvider(_caseId));

    final isLoading = conversationsAsync.isLoading ||
        userAsync.isLoading ||
        messagesAsync.isLoading ||
        caseDetailAsync.isLoading;
    if (isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: AppLoadingIndicator()),
        bottomNavigationBar: _navBar(context),
      );
    }

    return ChatTemplate(
      appBar: appBar,
      chatPanel: ChatPanel(
        messageList: ChatMessageList(messages: messagesAsync.value ?? const []),
        controller: _chatController,
        onSubmit: _sendMessage,
      ),
      drawer: ConversationDrawer(
        conversations: conversationsAsync.value ?? const [],
        userName: userAsync.value?.name,
        userInitials: userAsync.value?.initials,
      ),
      findingsPanel: FindingsPanel(
        findings: caseDetailAsync.value?.findings ?? const [],
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
