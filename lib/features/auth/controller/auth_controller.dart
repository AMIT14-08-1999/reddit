import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/repository/auth_repo.dart';
import 'package:reddit/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
    (ref) =>
        AuthController(ref: ref, authRepo: ref.watch(authRepositoryProvider)));

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepo _authRepo;
  final Ref _ref;
  AuthController({required AuthRepo authRepo, required Ref ref})
      : _authRepo = authRepo,
        _ref = ref,
        super(false);
  Stream<User?> get authStateChange => _authRepo.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFormLogin) async {
    state = true;
    final user = await _authRepo.signInWithGoogle(isFormLogin);
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) => _ref.read(userProvider.notifier).update(
            (state) => userModel,
          ),
    );
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepo.signInAsGuest();
    state = false;
    user.fold(
      (l) => showSnackBar(context, l.message),
      (userModel) => _ref.read(userProvider.notifier).update(
            (state) => userModel,
          ),
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepo.getUserData(uid);
  }

  void logOut() async {
    _authRepo.logOut();
  }
}
