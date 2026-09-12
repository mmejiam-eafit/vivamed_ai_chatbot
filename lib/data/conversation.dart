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

class ChatMessageItem {
  const ChatMessageItem({
    required this.message,
    required this.isUser,
    this.avatarImageUrl,
    this.avatarInitials,
    this.timestamp,
  });

  final String message;
  final bool isUser;
  final String? avatarImageUrl;
  final String? avatarInitials;
  final String? timestamp;
}
