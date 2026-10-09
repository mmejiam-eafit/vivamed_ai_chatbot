import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_image.dart';
import 'package:radiologist_helper/ui/atoms/app_loading_indicator.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/organisms/chat_message_list.dart';
import 'package:radiologist_helper/ui/organisms/chat_panel.dart';
import 'package:radiologist_helper/ui/organisms/conversation_drawer.dart';
import 'package:radiologist_helper/ui/organisms/findings_panel.dart';
import 'package:radiologist_helper/ui/organisms/primary_nav_drawer.dart';
import 'package:radiologist_helper/ui/pages/case_list_page.dart';
import 'package:radiologist_helper/ui/pages/chat_page.dart';
import 'package:radiologist_helper/ui/pages/heatmap_viewer_page.dart';
import 'package:radiologist_helper/ui/pages/settings_page.dart';
import 'package:radiologist_helper/ui/pages/similar_cases_page.dart';
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

  // Study Review isn't itself one of the 4 primary destinations (it's a
  // drill-down page), so every case is handled -- none skipped -- and
  // nothing shows as selected in the drawer.
  void _onPrimaryDestinationSelected(BuildContext context, int i) {
    switch (i) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
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
        selectedIndex: null,
        onDestinationSelected: (i) => _onPrimaryDestinationSelected(context, i),
      );

  Widget _conversationDrawer(
    BuildContext context,
    AsyncValue<List<ConversationItem>> conversationsAsync,
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
  /// ends up inside once StudyReviewTemplate places it, not this page's own
  /// context, which sits above it.
  Widget _conversationDrawerWide(
    BuildContext context,
    AsyncValue<List<ConversationItem>> conversationsAsync,
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
        userName: user?.name,
        userInitials: user?.initials,
        onMenuTap: () => Scaffold.of(context).openDrawer(),
        isWide: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Study Review'));
    final conversationsAsync = ref.watch(conversationsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(messagesProvider(_conversationId));
    final caseDetailAsync = ref.watch(caseDetailProvider(widget.caseId));

    return StudyReviewTemplate(
      appBar: appBar,
      // Routed through the template (rather than an early-return Scaffold)
      // so its own tier-aware chrome -- appBar hidden, primaryNavDrawer via
      // drawerWide -- still applies while providers are resolving, not just
      // once they've loaded.
      imageViewer: caseDetailAsync.when(
        // contain, not cover: the viewer slot fills its cell (the template
        // stretches it), and cover would crop the study to fill that cell.
        // Pixel data is evidence -- the dark canvas the template grounds it in
        // is the surround for exactly this (DL §3.7).
        data: (detail) =>
            AppImage(url: detail.detail.imageUrl, fit: BoxFit.contain),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stackTrace) =>
            Center(child: AppText('Could not load image: $error')),
      ),
      findingsPanel: caseDetailAsync.when(
        data: (detail) => FindingsPanel(
          findings: detail.findings,
          onFindingTap: (findingId) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HeatmapViewerPage(findingId: findingId),
            ),
          ),
          actionLabel: 'View Similar Studies',
          onActionTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SimilarCasesPage(caseId: widget.caseId),
            ),
          ),
        ),
        loading: () => const Center(child: AppLoadingIndicator()),
        error: (error, stackTrace) =>
            Center(child: AppText('Could not load findings: $error')),
      ),
      chatPanel: ChatPanel(
        messageList: messagesAsync.when(
          data: (messages) => ChatMessageList(messages: messages),
          loading: () => const Center(child: AppLoadingIndicator()),
          error: (error, stackTrace) =>
              Center(child: AppText('Could not load messages: $error')),
        ),
        controller: _chatController,
        onSubmit: _sendMessage,
      ),
      drawer: _conversationDrawer(
        context,
        conversationsAsync,
        userAsync.valueOrNull,
      ),
      drawerWide: _conversationDrawerWide(
        context,
        conversationsAsync,
        userAsync.valueOrNull,
      ),
      primaryNavDrawer: _primaryNavDrawer(context),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'wide', size: Size(1120, 768), wrapper: previewWrapperFull)
Widget previewStudyReviewPageWide() => const StudyReviewPage(caseId: 'case-1');

@Preview(name: 'narrow', size: Size(390, 844), wrapper: previewWrapperFull)
Widget previewStudyReviewPageNarrow() => const StudyReviewPage(caseId: 'case-1');
