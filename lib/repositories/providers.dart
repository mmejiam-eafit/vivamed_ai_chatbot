import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/repositories/auth_repository.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/chat_stream_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';
import 'package:radiologist_helper/repositories/heatmap_repository.dart';
import 'package:radiologist_helper/repositories/onboarding_repository.dart';
import 'package:radiologist_helper/repositories/upload_repository.dart';
import 'package:radiologist_helper/repositories/user_repository.dart';

// The one place Mock repositories are named -- swapping to a real backend
// later is a one-line change per provider, nothing else in the app changes.

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => MockAuthRepository());

final userRepositoryProvider =
    Provider<UserRepository>((ref) => MockUserRepository());

final caseRepositoryProvider =
    Provider<CaseRepository>((ref) => MockCaseRepository());

final findingsRepositoryProvider =
    Provider<FindingsRepository>((ref) => MockFindingsRepository());

final conversationRepositoryProvider =
    Provider<ConversationRepository>((ref) => MockConversationRepository());

// Streaming is its own repository, not a method on the conversation one: it is
// the backend's single streaming POST, which can go live before the
// conversation list/history endpoints do. Still the Mock -- connecting it means
// `HttpChatStreamRepository(client: ..., endpoint: ...)` here, once the backend
// is reachable.
final chatStreamRepositoryProvider =
    Provider<ChatStreamRepository>((ref) => MockChatStreamRepository());

final heatmapRepositoryProvider =
    Provider<HeatmapRepository>((ref) => MockHeatmapRepository());

final uploadRepositoryProvider =
    Provider<UploadRepository>((ref) => MockUploadRepository());

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => SharedPreferencesOnboardingRepository(),
);
