import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/auth_service.dart';
import 'package:radiologist_helper/services/case_service.dart';
import 'package:radiologist_helper/services/chat_service.dart';
import 'package:radiologist_helper/services/heatmap_service.dart';
import 'package:radiologist_helper/services/onboarding_service.dart';
import 'package:radiologist_helper/services/upload_service.dart';

// ── Service instances ───────────────────────────────────────────────────────
// Each service receives its repositories via ref.watch on
// repositories/providers.dart -- it never constructs one itself.

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  ),
);

final caseServiceProvider = Provider<CaseService>(
  (ref) => CaseService(
    ref.watch(caseRepositoryProvider),
    ref.watch(findingsRepositoryProvider),
  ),
);

final chatServiceProvider = Provider<ChatService>(
  (ref) => ChatService(ref.watch(conversationRepositoryProvider)),
);

final heatmapServiceProvider = Provider<HeatmapService>(
  (ref) => HeatmapService(ref.watch(heatmapRepositoryProvider)),
);

final uploadServiceProvider = Provider<UploadService>(
  (ref) => UploadService(ref.watch(uploadRepositoryProvider)),
);

final onboardingServiceProvider = Provider<OnboardingService>(
  (ref) => OnboardingService(ref.watch(onboardingRepositoryProvider)),
);

// ── Screen-facing reactive providers ────────────────────────────────────────
// What pages actually read -- AsyncValue gives loading/data/error for free.

final currentUserProvider = FutureProvider<UserProfile>(
  (ref) => ref.watch(authServiceProvider).getCurrentUser(),
);

final casesProvider = FutureProvider<List<CaseSummary>>(
  (ref) => ref.watch(caseServiceProvider).getCases(),
);

final caseDetailProvider = FutureProvider.family<
    ({CaseDetail detail, List<FindingItem> findings}), String>(
  (ref, caseId) => ref.watch(caseServiceProvider).getCaseDetail(caseId),
);

final similarCasesProvider = FutureProvider.family<List<CaseSummary>, String>(
  (ref, caseId) => ref.watch(caseServiceProvider).getSimilarCases(caseId),
);

final conversationsProvider = FutureProvider<List<ConversationItem>>(
  (ref) => ref.watch(chatServiceProvider).getConversations(),
);

final messagesProvider = FutureProvider.family<List<ChatMessageItem>, String>(
  (ref, conversationId) => ref.watch(chatServiceProvider).getMessages(conversationId),
);

final heatmapProvider = FutureProvider.family<HeatmapData, String>(
  (ref, findingId) => ref.watch(heatmapServiceProvider).getHeatmap(findingId),
);
