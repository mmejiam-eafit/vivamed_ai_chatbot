import 'package:radiologist_helper/data/mocks/user_mocks.dart';
import 'package:radiologist_helper/data/user.dart';

abstract class AuthRepository {
  Future<UserProfile> signIn({required String email, required String password});
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    // Nothing to validate against yet -- any credentials "succeed."
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockCurrentUser;
  }
}
