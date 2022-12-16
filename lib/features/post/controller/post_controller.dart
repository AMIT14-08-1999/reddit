import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/providers/storage_repo_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/enums/enums.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/repository/add_post_repo.dart';
import 'package:reddit/models/comment_model.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepoProvider);
  final storageRepo = ref.watch(storageRepositoryProvider);
  return PostController(
    ref: ref,
    postRepo: postRepository,
    storageRepo: storageRepo,
  );
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});
final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});
final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});
final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComment(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepo _postRepo;
  final Ref _ref;
  final StorageRepo _storageRepo;
  PostController({
    required Ref ref,
    required PostRepo postRepo,
    required StorageRepo storageRepo,
  })  : _postRepo = postRepo,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectCommunity,
    required String description,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityProfilePic: selectCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      communityName: selectCommunity.name,
      username: user.name,
      description: description,
    );
    final res = await _postRepo.addPost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
          UserKarma.textPost,
        );
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectCommunity,
    required String link,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      communityProfilePic: selectCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      communityName: selectCommunity.name,
      username: user.name,
      link: link,
    );
    final res = await _postRepo.addPost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
          UserKarma.linkPost,
        );
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Posted Successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectCommunity,
    required File? image,
  }) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepo.storeFile(
        path: 'posts/${selectCommunity.name}', id: postId, file: image);
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        communityProfilePic: selectCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        communityName: selectCommunity.name,
        username: user.name,
        link: r,
      );

      final res = await _postRepo.addPost(post);
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
            UserKarma.imagePost,
          );
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Posted Successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepo.fetchIserPost(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepo.fetchGuestPost();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepo.deletePost(post);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
          UserKarma.deletePost,
        );
    res.fold(
        (l) => null, (r) => showSnackBar(context, "Post Deleted Successfully"));
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepo.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepo.downvote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepo.getPostById(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
  }) async {
    final user = _ref.read(userProvider)!;
    final commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      profilePic: user.profilePic,
      userName: user.name,
    );
    final res = await _postRepo.addCommment(comment);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(
          UserKarma.comment,
        );
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepo.awardPost(post, award, user.uid);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Comment>> fetchPostComment(String postId) {
    return _postRepo.getCommentsOfPost(postId);
  }
}
