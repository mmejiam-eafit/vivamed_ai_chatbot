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

/// A case named in a reply (e.g. "I found 2 similar cases: ..."), carrying
/// its own display title -- a real backend would return a reply with its
/// references already resolved like this, so `ChatBubble` never needs to
/// look a title up from an id at render time.
class CaseReference {
  const CaseReference({required this.caseId, required this.title});

  final String caseId;
  final String title;
}

class ChatMessageItem {
  const ChatMessageItem({
    required this.message,
    required this.isUser,
    this.avatarImageUrl,
    this.avatarInitials,
    this.timestamp,
    this.caseReferences,
  });

  final String message;
  final bool isUser;
  final String? avatarImageUrl;
  final String? avatarInitials;
  final String? timestamp;
  final List<CaseReference>? caseReferences;
}
