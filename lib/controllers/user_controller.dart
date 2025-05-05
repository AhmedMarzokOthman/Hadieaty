import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hive/hive.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firestore service');
    }
    return user.uid;
  }

  Future<Map<String, dynamic>> userExists() async {
    final user = await _firestore.collection("Store Data").doc(uid).get();
    return {"exists": user.exists, "data": user.data()};
  }

  Future<void> addUser(UserModel user) async {
    try {
      log('Adding user to Firestore: ${user.uid}', name: 'FirestoreService');
      await _firestore
          .collection("Store Data")
          .doc(user.uid)
          .set(user.toJson());
      log('User added successfully', name: 'FirestoreService');
    } catch (e) {
      log('Error adding user: $e', name: 'FirestoreService', error: e);
    }
  }

  Future<UserModel> getUser() async {
    final user = await _firestore.collection("Store Data").doc(uid).get();
    return UserModel.fromJson(user.data() ?? {});
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final users =
        await _firestore
            .collection("Store Data")
            .where("username", isEqualTo: username)
            .get();

    // Return null if no matching user is found
    if (users.docs.isEmpty) {
      return null;
    }

    return UserModel.fromJson(users.docs.first.data());
  }

  Future<UserModel?> getUserByUid(String uid) async {
    final user = await _firestore.collection("Store Data").doc(uid).get();
    return UserModel.fromJson(user.data() ?? {});
  }

  Future<void> deleteUser() async {
    await _firestore.collection("Store Data").doc(uid).delete();
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Update in Firestore
      await _firestore
          .collection("Store Data")
          .doc(user.uid)
          .update(user.toJson());

      // Update in Hive
      await saveUserToLocal(user);
    } catch (e) {
      log(
        'Error updating user profile: $e',
        name: 'FirestoreService',
        error: e,
      );
    }
  }

  Future<void> saveUserToLocal(UserModel user) async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.put(user.uid, user);
  }

  Future<UserModel?> getUserFromLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    // print('\x1B[32mUser: ${box.get(uid)}\x1B[0m');
    return box.get(uid);
  }

  Future<void> deleteUserFromLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.delete(uid);
  }

  Future<bool> userExistsInLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    return box.containsKey(uid);
  }

  Future<void> addFriend(String username) async {
    final currentUser = await getUser();
    final friendUid = await getUserByUsername(username);
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("friends")
        .doc(friendUid?.uid)
        .set(friendUid?.toJson() ?? {});

    await _firestore
        .collection("Store Data")
        .doc(friendUid?.uid)
        .collection("friends")
        .doc(uid)
        .set(currentUser.toJson());
  }

  Future<List<UserModel>> getFriends() async {
    final friends =
        await _firestore
            .collection("Store Data")
            .doc(uid)
            .collection("friends")
            .get();
    return friends.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  }

  Future<void> updateFriendReference(String friendUid, UserModel user) async {
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("friends")
        .doc(user.uid)
        .update(user.toJson());
  }

  Future<void> saveFriendToLocal(UserModel friend) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.put(friend.uid, friend);
  }

  Future<UserModel?> getFriendFromLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.get(uid);
  }

  Future<void> deleteFriendFromLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.delete(uid);
  }

  Future<void> deleteAllFriendsFromLocal() async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.clear();
  }

  Future<bool> friendExistsInLocal(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.containsKey(uid);
  }

  Future<List<UserModel>> getFriendsFromLocal() async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.values.toList();
  }
}
