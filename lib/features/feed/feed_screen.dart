import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/commons/error_text.dart';
import 'package:reddit/core/commons/loader.dart';
import 'package:reddit/core/commons/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controller/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    if (!isGuest) {
      return ref.watch(userCommunityProvider).when(
          data: (communities) => ref.watch(userPostsProvider(communities)).when(
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, index) {
                    final post = data[index];
                    return PostCard(post: post);
                  },
                );
              },
              error: (error, stackTrace) {
                return ErrorText(error: error.toString());
              },
              loading: () => Loader()),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader());
    }
    return ref.watch(userCommunityProvider).when(
        data: (communities) => ref.watch(guestPostsProvider).when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, index) {
                  final post = data[index];
                  return PostCard(post: post);
                },
              );
            },
            error: (error, stackTrace) {
              return ErrorText(error: error.toString());
            },
            loading: () => Loader()),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => Loader());
  }
}
