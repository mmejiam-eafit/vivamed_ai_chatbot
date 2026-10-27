import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/auth_service.dart';
import 'package:radiologist_helper/services/case_service.dart';
import 'package:radiologist_helper/services/chat_service.dart';
import 'package:radiologist_helper/services/chat_thread_notifier.dart';
import 'package:radiologist_helper/services/heatmap_service.dart';
import 'package:radiologist_helper/services/image_review_service.dart';
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
  (ref) => ChatService(
    ref.watch(conversationRepositoryProvider),
    ref.watch(chatStreamRepositoryProvider),
  ),
);

final heatmapServiceProvider = Provider<HeatmapService>(
  (ref) => HeatmapService(ref.watch(heatmapRepositoryProvider)),
);

final imageReviewServiceProvider = Provider<ImageReviewService>(
  (ref) => ImageReviewService(ref.watch(imageReviewRepositoryProvider)),
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

// Not a FutureProvider: besides the fetched history it holds the reply
// currently streaming in, and takes `.notifier.send(text)`. Pages still read it
// as an `AsyncValue<List<ChatMessageItem>>`.
final messagesProvider = AsyncNotifierProvider.family<ChatThreadNotifier,
    List<ChatMessageItem>, String>(ChatThreadNotifier.new);

final heatmapProvider = FutureProvider.family<HeatmapData, String>(
  (ref, findingId) => ref.watch(heatmapServiceProvider).getHeatmap(findingId),
);

// Every review, needs review first. After a decision the page invalidates this
// one provider; everything below derives from it.
final imageReviewsProvider = FutureProvider<List<ImageReview>>(
  (ref) => ref.watch(imageReviewServiceProvider).getReviews(),
);

final reviewQueueProvider = FutureProvider<List<ReviewQueueItem>>((ref) async {
  final service = ref.watch(imageReviewServiceProvider);
  final reviews = await ref.watch(imageReviewsProvider.future);
  final cases = await ref.watch(casesProvider.future);
  return service.queue(reviews, cases);
});

// What the Review destination's badge shows. 0 while the reviews load or if
// they fail: a missing count is not worth an error in the navigation.
final pendingReviewCountProvider = Provider<int>((ref) {
  final reviews = ref.watch(imageReviewsProvider).value;
  if (reviews == null) return 0;
  return ref.watch(imageReviewServiceProvider).pendingCount(reviews);
});

// Empty while the reviews load or if they fail, like the count above.
final heldBackReviewsByCaseProvider =
    Provider<Map<String, List<ImageReview>>>((ref) {
  final reviews = ref.watch(imageReviewsProvider).value;
  if (reviews == null) return const {};
  return ref.watch(imageReviewServiceProvider).heldBackByCase(reviews);
});
