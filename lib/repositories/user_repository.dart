import 'package:radiologist_helper/data/mocks/user_mocks.dart';
import 'package:radiologist_helper/data/user.dart';

abstract class UserRepository {
  Future<UserProfile> getCurrentUser();
}

class MockUserRepository implements UserRepository {
  @override
  Future<UserProfile> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return mockCurrentUser;
  }
}
