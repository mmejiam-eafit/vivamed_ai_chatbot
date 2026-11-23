import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/auth_repository.dart';
import 'package:radiologist_helper/repositories/user_repository.dart';

class AuthService {
  AuthService(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  /// Signs in with the username, the name the user signs in with: the
  /// backend refuses an email until real users are decided.
  Future<UserProfile> signIn({
    required String username,
    required String password,
  }) =>
      _authRepository.signIn(username: username, password: password);

  Future<UserProfile> getCurrentUser() => _userRepository.getCurrentUser();
}
