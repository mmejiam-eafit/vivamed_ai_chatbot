import 'package:radiologist_helper/data/user.dart';
import 'package:radiologist_helper/repositories/auth_repository.dart';
import 'package:radiologist_helper/repositories/user_repository.dart';

class AuthService {
  AuthService(this._authRepository, this._userRepository);

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<UserProfile> signIn({required String email, required String password}) =>
      _authRepository.signIn(email: email, password: password);

  Future<UserProfile> getCurrentUser() => _userRepository.getCurrentUser();
}
