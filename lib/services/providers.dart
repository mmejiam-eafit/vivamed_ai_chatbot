import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/data/case.dart';
import 'package:radiologist_helper/data/conversation.dart';
import 'package:radiologist_helper/data/finding.dart';
import 'package:radiologist_helper/data/heatmap.dart';
import 'package:radiologist_helper/data/image_review.dart';
import 'package:radiologist_helper/data/processing.dart';
import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/providers.dart';
import 'package:radiologist_helper/services/auth_service.dart';
import 'package:radiologist_helper/services/case_service.dart';
import 'package:radiologist_helper/services/chat_service.dart';
import 'package:radiologist_helper/services/chat_thread_notifier.dart';
import 'package:radiologist_helper/services/heatmap_service.dart';
import 'package:radiologist_helper/services/image_review_service.dart';
import 'package:radiologist_helper/services/onboarding_service.dart';
import 'package:radiologist_helper/services/processing_service.dart';
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

final processingServiceProvider = Provider<ProcessingService>(
  (ref) => ProcessingService(ref.watch(processingRepositoryProvider)),
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

// Every study, read once: what the review queue matches its reviews to.
final casesProvider = FutureProvider<List<CaseSummary>>(
  (ref) => ref.watch(caseServiceProvider).getCases(),
);

// The Studies worklist, read again while any study is queued or processing.
// Not auto-disposed, so going back to the page shows the last list at once:
// Riverpod pauses the stream, and with it the reads, whenever no visible
// widget watches it, and resuming reads again at once.
final worklistProvider = StreamProvider<List<CaseSummary>>(
  (ref) => ref.watch(caseServiceProvider).watchCases(),
);

final caseDetailProvider = FutureProvider.family<
    ({CaseDetail detail, List<FindingItem> findings}), String>(
  (ref, caseId) => ref.watch(caseServiceProvider).getCaseDetail(caseId),
);

final similarCasesProvider = FutureProvider.family<SimilarCases, String>(
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

// One run's progress, read again until it ends. Auto-disposed, unlike every
// other provider here: polling must stop once no page shows the run.
final processingRunProvider =
    StreamProvider.autoDispose.family<ProcessingRun, String>(
  (ref, runId) => ref.watch(processingServiceProvider).watchRun(runId),
);

// Every study's open failures, by case id. After a retry or discard the page
// invalidates this one provider; the map below derives from it.
final processingFailuresProvider =
    FutureProvider<Map<String, List<ProcessingFailure>>>(
  (ref) => ref.watch(processingServiceProvider).failuresByCase(),
);

// Empty while the failures load or if they fail: Study Review's link to them
// is not worth an error of its own.
final openFailuresByCaseProvider =
    Provider<Map<String, List<ProcessingFailure>>>(
  (ref) => ref.watch(processingFailuresProvider).value ?? const {},
);
