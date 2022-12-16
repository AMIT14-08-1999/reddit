import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/providers/storage_repo_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/enums/enums.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:reddit/user_profile/repository/user_profile_repo.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepo = ref.watch(userProfileRepoProvider);
  final storageRepo = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    ref: ref,
    userProfileRepo: userProfileRepo,
    storageRepo: storageRepo,
  );
});
final getUserPostProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepo _userProfileRepo;
  final Ref _ref;
  final StorageRepo _storageRepo;
  UserProfileController({
    required Ref ref,
    required UserProfileRepo userProfileRepo,
    required StorageRepo storageRepo,
  })  : _userProfileRepo = userProfileRepo,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);
  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepo.storeFile(
        path: 'users/profile',
        id: user.name,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(
          profilePic: r,
        ),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepo.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(
          banner: r,
        ),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepo.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepo.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepo.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
