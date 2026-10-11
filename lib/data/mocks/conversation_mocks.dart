import 'package:radiologist_helper/data/conversation.dart';

final mockConversations = <ConversationItem>[
  const ConversationItem(
    id: 'conv-1',
    title: 'Chest X-Ray — Patient 1',
    subtitle: '2h ago',
  ),
  const ConversationItem(
    id: 'conv-2',
    title: 'Abdominal CT — Patient 2',
    subtitle: 'Yesterday',
  ),
  const ConversationItem(
    id: 'conv-3',
    title: 'Chest CT — Lung Nodule',
    subtitle: '3 days ago',
  ),
  const ConversationItem(
    id: 'conv-4',
    title: 'Brain MRI — Patient 4',
    subtitle: 'Last week',
  ),
  const ConversationItem(
    id: 'conv-5',
    title: 'Knee MRI — Patient 5',
    subtitle: '2 weeks ago',
  ),
];

// Mutable so the mock repositories can append to it -- a stand-in for a real
// backend persisting the message.
final _mockMessages = <String, List<ChatMessageItem>>{
  'conv-1': [
    const ChatMessageItem(
      id: 'conv-1-msg-1',
      message: 'Can you identify the main finding?',
      isUser: true,
      timestamp: '09:14',
    ),
    const ChatMessageItem(
      id: 'conv-1-msg-2',
      message:
          'There is right lower lobe consolidation consistent with pneumonia.',
      isUser: false,
    ),
    const ChatMessageItem(
      id: 'conv-1-msg-3',
      message: 'Is there any pleural effusion?',
      isUser: true,
      timestamp: '09:15',
    ),
    const ChatMessageItem(
      id: 'conv-1-msg-4',
      message: 'No effusion is seen on this study.',
      isUser: false,
    ),
    const ChatMessageItem(
      id: 'conv-1-msg-5',
      message: 'I found 2 similar cases you might want to review.',
      isUser: false,
      caseReferences: [
        CaseReference(caseId: 'case-2', title: 'Abdominal CT'),
        CaseReference(caseId: 'case-3', title: 'Chest CT — Lung Nodule'),
      ],
    ),
  ],
  'conv-2': [
    const ChatMessageItem(
      id: 'conv-2-msg-1',
      message: 'Any acute abdominal findings?',
      isUser: true,
      timestamp: '14:02',
    ),
    const ChatMessageItem(
      id: 'conv-2-msg-2',
      message: 'No acute findings identified in the abdomen or pelvis.',
      isUser: false,
    ),
  ],
  'conv-3': [
    const ChatMessageItem(
      id: 'conv-3-msg-1',
      message: 'Flag anything urgent first.',
      isUser: true,
      timestamp: '08:41',
    ),
    const ChatMessageItem(
      id: 'conv-3-msg-2',
      message:
          'Tension pneumothorax on the right — this needs immediate attention.',
      isUser: false,
    ),
  ],
  'conv-4': [
    const ChatMessageItem(
      id: 'conv-4-msg-1',
      message: 'Summarize the MRI.',
      isUser: true,
      timestamp: '11:20',
    ),
    const ChatMessageItem(
      id: 'conv-4-msg-2',
      message: 'Mild cerebral atrophy, otherwise unremarkable.',
      isUser: false,
    ),
  ],
  'conv-5': [
    const ChatMessageItem(
      id: 'conv-5-msg-1',
      message: 'Any ligament tears?',
      isUser: true,
      timestamp: '16:47',
    ),
    const ChatMessageItem(
      id: 'conv-5-msg-2',
      message: 'No ligamentous injury identified.',
      isUser: false,
    ),
  ],
};

List<ChatMessageItem> mockMessagesFor(String conversationId) =>
    _mockMessages[conversationId] ?? const [];

/// Persists [message] as given -- its id included, which is how a real backend
/// stores a streamed reply under the id the stream announced.
void appendMockMessage(String conversationId, ChatMessageItem message) =>
    _mockMessages.putIfAbsent(conversationId, () => []).add(message);

ChatMessageItem addMockMessage(String conversationId, String text) {
  final existing = _mockMessages[conversationId]?.length ?? 0;
  final message = ChatMessageItem(
    id: '$conversationId-msg-${existing + 1}',
    message: text,
    isUser: true,
  );
  appendMockMessage(conversationId, message);
  return message;
}

/// What `MockChatStreamRepository` streams back. A placeholder that says so,
/// not authored clinical content -- there is no model behind it.
const mockAssistantReply =
    'This is a simulated reply from the mock chat repository. '
    'No AI model is connected yet.';
