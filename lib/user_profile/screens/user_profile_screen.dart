import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/commons/error_text.dart';
import 'package:reddit/core/commons/loader.dart';
import 'package:reddit/core/commons/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/user_profile/controller/user_profile_controller.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateTpEditUser(BuildContext context) {
    Routemaster.of(context).push("/edit-profile/$uid");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
          data: (user) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              user.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(user.profilePic),
                              radius: 35,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () => navigateTpEditUser(context),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 25),
                              ),
                              child: Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "u/${user.name}",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                '${user.karma} karma',
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              thickness: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: ref.watch(getUserPostProvider(uid)).when(
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
                        return ErrorText(
                          error: error.toString(),
                        );
                      },
                      loading: () => Loader(),
                    ),
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
