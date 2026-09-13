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

// Mutable so MockConversationRepository.sendMessage can append to it -- a
// stand-in for a real backend persisting the message.
final _mockMessages = <String, List<ChatMessageItem>>{
  'conv-1': [
    const ChatMessageItem(
      message: 'Can you identify the main finding?',
      isUser: true,
      timestamp: '09:14',
    ),
    const ChatMessageItem(
      message:
          'There is right lower lobe consolidation consistent with pneumonia.',
      isUser: false,
    ),
    const ChatMessageItem(
      message: 'Is there any pleural effusion?',
      isUser: true,
      timestamp: '09:15',
    ),
    const ChatMessageItem(
      message: 'No effusion is seen on this study.',
      isUser: false,
    ),
    const ChatMessageItem(
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
      message: 'Any acute abdominal findings?',
      isUser: true,
      timestamp: '14:02',
    ),
    const ChatMessageItem(
      message: 'No acute findings identified in the abdomen or pelvis.',
      isUser: false,
    ),
  ],
  'conv-3': [
    const ChatMessageItem(
      message: 'Flag anything urgent first.',
      isUser: true,
      timestamp: '08:41',
    ),
    const ChatMessageItem(
      message:
          'Tension pneumothorax on the right — this needs immediate attention.',
      isUser: false,
    ),
  ],
  'conv-4': [
    const ChatMessageItem(
      message: 'Summarize the MRI.',
      isUser: true,
      timestamp: '11:20',
    ),
    const ChatMessageItem(
      message: 'Mild cerebral atrophy, otherwise unremarkable.',
      isUser: false,
    ),
  ],
  'conv-5': [
    const ChatMessageItem(
      message: 'Any ligament tears?',
      isUser: true,
      timestamp: '16:47',
    ),
    const ChatMessageItem(
      message: 'No ligamentous injury identified.',
      isUser: false,
    ),
  ],
};

List<ChatMessageItem> mockMessagesFor(String conversationId) =>
    _mockMessages[conversationId] ?? const [];

ChatMessageItem addMockMessage(String conversationId, String text) {
  final message = ChatMessageItem(message: text, isUser: true);
  _mockMessages.putIfAbsent(conversationId, () => []).add(message);
  return message;
}
