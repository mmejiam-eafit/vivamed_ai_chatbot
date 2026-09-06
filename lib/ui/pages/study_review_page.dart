import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

class StudyReviewPage extends StatefulWidget {
  const StudyReviewPage({super.key});

  @override
  State<StudyReviewPage> createState() => _StudyReviewPageState();
}

class _StudyReviewPageState extends State<StudyReviewPage> {
  final _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StudyReviewTemplate(
      appBar: AppBar(title: const Text('Study Review')),
      imageViewer: const Placeholder(),
      findingsPanel: const FindingsPanel(findings: []),
      chatPanel: ChatPanel(
        messageList: const ChatMessageList(messages: []),
        controller: _chatController,
        onSubmit: () {},
      ),
      drawer: const ConversationDrawer(conversations: []),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewStudyReviewPageWide() => const StudyReviewPage();

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewStudyReviewPageNarrow() => const StudyReviewPage();
