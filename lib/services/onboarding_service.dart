import 'package:radiologist_helper/repositories/onboarding_repository.dart';

class OnboardingService {
  OnboardingService(this._onboardingRepository);

  final OnboardingRepository _onboardingRepository;

  Future<bool> hasCompletedOnboarding() =>
      _onboardingRepository.hasCompletedOnboarding();

  Future<void> markCompleted() => _onboardingRepository.markCompleted();
}
