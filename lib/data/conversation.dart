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

/// Where a message is in its life. Only an assistant reply is ever anything
/// but [complete] -- it is [streaming] while text is still arriving and
/// [failed] if the stream broke before finishing.
enum ChatMessageStatus { complete, streaming, failed }

class ChatMessageItem {
  const ChatMessageItem({
    required this.id,
    required this.message,
    required this.isUser,
    this.status = ChatMessageStatus.complete,
    this.avatarImageUrl,
    this.avatarInitials,
    this.timestamp,
    this.caseReferences,
  });

  /// Stable and unique within a conversation. A streamed reply keeps one id
  /// from its first chunk to its last, which is what lets each update replace
  /// the previous snapshot of the same message instead of appending.
  final String id;
  final String message;
  final bool isUser;
  final ChatMessageStatus status;
  final String? avatarImageUrl;
  final String? avatarInitials;
  final String? timestamp;
  final List<CaseReference>? caseReferences;

  /// Only the fields a stream changes -- `id` (a placeholder swapped for the
  /// server's), `message` (growing) and `status`.
  ChatMessageItem copyWith({
    String? id,
    String? message,
    ChatMessageStatus? status,
  }) =>
      ChatMessageItem(
        id: id ?? this.id,
        message: message ?? this.message,
        isUser: isUser,
        status: status ?? this.status,
        avatarImageUrl: avatarImageUrl,
        avatarInitials: avatarInitials,
        timestamp: timestamp,
        caseReferences: caseReferences,
      );
}
