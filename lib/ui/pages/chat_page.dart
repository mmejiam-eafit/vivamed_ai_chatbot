import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/templates/chat_template.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChatTemplate(
      appBar: AppBar(title: const Text('Chat')),
      chatPanel: ChatPanel(
        messageList: const ChatMessageList(messages: []),
        controller: _chatController,
        onSubmit: () {},
      ),
      drawer: const ConversationDrawer(conversations: []),
      findingsPanel: const FindingsPanel(findings: []),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewChatPageWide() => const ChatPage();

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewChatPageNarrow() => const ChatPage();
