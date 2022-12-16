import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/storage_repo_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/repository/communitory_repo.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunityProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});
final getCommunityPostProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepo = ref.watch(communityRepoProvider);
  final storageRepo = ref.watch(storageRepositoryProvider);
  return CommunityController(
    ref: ref,
    communityRepo: communityRepo,
    storageRepo: storageRepo,
  );
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});
final searchProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepo _communityRepo;
  final Ref _ref;
  final StorageRepo _storageRepo;
  CommunityController({
    required Ref ref,
    required CommunityRepo communityRepo,
    required StorageRepo storageRepo,
  })  : _communityRepo = communityRepo,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? "";
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepo.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepo.getUserCommunities(uid);
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;
    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepo.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepo.joinCommunity(community.name, user.uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackBar(context, "Community Leave Successfully");
      } else {
        showSnackBar(context, "Community Join Successfully");
      }
    });
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepo.getCommunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepo.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(
          avatar: r,
        ),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepo.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(
          banner: r,
        ),
      );
    }
    final res = await _communityRepo.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepo.searchCommunity(query);
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepo.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepo.getCommunityPosts(name);
  }
}
