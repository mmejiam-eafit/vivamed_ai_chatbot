import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/templates/study_review_template.dart';

class StudyReviewPage extends ConsumerStatefulWidget {
  const StudyReviewPage({super.key, required this.caseId, this.conversationId});

  final String caseId;

  /// When arrived from standalone Chat, that conversation continues. When
  /// absent (Case List, Similar Cases, a fresh Upload), defaults to
  /// [caseId] itself -- this study's own thread, per `app_navigation_plan.md`.
  final String? conversationId;

  @override
  ConsumerState<StudyReviewPage> createState() => _StudyReviewPageState();
}

class _StudyReviewPageState extends ConsumerState<StudyReviewPage> {
  final _chatController = TextEditingController();

  String get _conversationId => widget.conversationId ?? widget.caseId;

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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Study Review'));
    final conversationsAsync = ref.watch(conversationsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(messagesProvider(_conversationId));
    final caseDetailAsync = ref.watch(caseDetailProvider(widget.caseId));

    final isLoading = conversationsAsync.isLoading ||
        userAsync.isLoading ||
        messagesAsync.isLoading ||
        caseDetailAsync.isLoading;
    if (isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: AppLoadingIndicator()),
      );
    }

    return StudyReviewTemplate(
      appBar: appBar,
      imageViewer: AppImage(
        url: caseDetailAsync.value?.detail.imageUrl ?? '',
        fit: BoxFit.cover,
      ),
      findingsPanel: FindingsPanel(
        findings: caseDetailAsync.value?.findings ?? const [],
      ),
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
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1024, 768), wrapper: previewWrapperFull)
Widget previewStudyReviewPageWide() => const StudyReviewPage(caseId: 'case-1');

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewStudyReviewPageNarrow() => const StudyReviewPage(caseId: 'case-1');
