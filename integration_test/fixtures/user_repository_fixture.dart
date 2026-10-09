import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/user_repository.dart';

import 'fixture_result.dart';

/// Mutable -- a test can reassign a result between calls without
/// re-overriding the provider.
class UserRepositoryFixture implements UserRepository {
  UserRepositoryFixture({this.getCurrentUserResult});

  FixtureResult<UserProfile>? getCurrentUserResult;

  @override
  Future<UserProfile> getCurrentUser() =>
      getCurrentUserResult?.resolve() ?? _unconfigured('getCurrentUser');
}

Never _unconfigured(String method) => throw UnimplementedError(
    'UserRepositoryFixture.$method not configured for this test');
