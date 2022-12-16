import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/enums/enums.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';

final userProfileRepoProvider = Provider((ref) {
  return UserProfileRepo(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepo {
  final FirebaseFirestore _firestore;

  UserProfileRepo({required FirebaseFirestore firestore})
      : _firestore = firestore;
  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
  FutureVoid editProfile(UserModel user) async {
    try {
      return right(
        _user.doc(user.uid).update(
              user.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Post.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(
        _user.doc(user.uid).update(
             {
              'karma':user.karma,
             }
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }
}
