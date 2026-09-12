import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/repositories/auth_repository.dart';
import 'package:radiologist_helper/repositories/case_repository.dart';
import 'package:radiologist_helper/repositories/conversation_repository.dart';
import 'package:radiologist_helper/repositories/findings_repository.dart';
import 'package:radiologist_helper/repositories/heatmap_repository.dart';
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

final heatmapRepositoryProvider =
    Provider<HeatmapRepository>((ref) => MockHeatmapRepository());
