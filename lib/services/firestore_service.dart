import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'dart:developer' as developer;
import 'package:hadieaty/services/hive_service.dart';

class FirestoreService {
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
      developer.log(
        'Adding user to Firestore: ${user.uid}',
        name: 'FirestoreService',
      );
      await _firestore
          .collection("Store Data")
          .doc(user.uid)
          .set(user.toJson());
      developer.log('User added successfully', name: 'FirestoreService');
    } catch (e) {
      developer.log(
        'Error adding user: $e',
        name: 'FirestoreService',
        error: e,
      );
      throw e;
    }
  }

  Future<UserModel> getUser() async {
    final user = await _firestore.collection("Store Data").doc(uid).get();
    return UserModel.fromJson(user.data() ?? {});
  }

  Future<void> deleteUser() async {
    await _firestore.collection("Store Data").doc(uid).delete();
  }

  Future<void> addWish(WishModel wish) async {
    try {
      final currentUid = uid;
      developer.log(
        'Adding wish to Firestore for user: $currentUid, Wish ID: ${wish.id}',
        name: 'FirestoreService',
      );
      developer.log('Wish data: ${wish.toJson()}', name: 'FirestoreService');

      await _firestore
          .collection("Store Data")
          .doc(currentUid)
          .collection("wishes")
          .doc(wish.id)
          .set(wish.toJson());

      developer.log(
        'Wish added successfully to Firestore',
        name: 'FirestoreService',
      );
    } catch (e) {
      developer.log(
        'Error adding wish to Firestore: $e',
        name: 'FirestoreService',
        error: e,
      );
      throw e;
    }
  }

  Future<List<WishModel>> getWishes() async {
    final wishes =
        await _firestore
            .collection("Store Data")
            .doc(uid)
            .collection("wishes")
            .get();
    return wishes.docs.map((doc) => WishModel.fromJson(doc.data())).toList();
  }

  Future<int> getWishesCount() async {
    final wishes = await getWishes();
    return wishes.length;
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

  Future<List<WishModel>> getFriendWishes(String friendUid) async {
    try {
      final wishesSnapshot =
          await _firestore
              .collection("Store Data")
              .doc(friendUid)
              .collection("wishes")
              .get();

      return wishesSnapshot.docs
          .map((doc) => WishModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // print('Error getting friend wishes: $e');
      return [];
    }
  }

  Future<List<EventModel>> getFriendEvents(String friendUid) async {
    try {
      final eventsSnapshot =
          await _firestore
              .collection("Store Data")
              .doc(friendUid)
              .collection("events")
              .get();

      return eventsSnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // print('Error getting friend events: $e');
      return [];
    }
  }

  Future<void> editWish(WishModel wish) async {
    developer.log(
      'Editing wish in Firestore: ${wish.id}',
      name: 'FirestoreService',
    );
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("wishes")
        .doc(wish.id)
        .update(wish.toJson());
  }

  Future<void> deleteWish(String id) async {
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("wishes")
        .doc(id)
        .delete();
  }

  Future<void> addEvent(EventModel event) async {
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("events")
        .doc(event.id)
        .set(event.toJson());
  }

  Future<List<EventModel>> getEvents() async {
    final events =
        await _firestore
            .collection("Store Data")
            .doc(uid)
            .collection("events")
            .get();
    return events.docs.map((doc) => EventModel.fromJson(doc.data())).toList();
  }

  Future<void> editEvent(EventModel event) async {
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("events")
        .doc(event.id)
        .update(event.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("events")
        .doc(id)
        .delete();
  }

  Future<void> pledgeGift(String friendUid, WishModel gift) async {
    final currentUser = await getUser();
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("wishes")
        .doc(gift.id)
        .update({
          "pledgedBy": {"pldgerUid": uid, "pldgerName": currentUser.name},
        });

    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("myPledgedGifts")
        .doc(gift.id)
        .set({"gift": gift.toJson(), "friendUid": friendUid});
  }

  Future<void> unpledgeGift(String friendUid, String giftId) async {
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("wishes")
        .doc(giftId)
        .update({"pledgedBy": null});

    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("myPledgedGifts")
        .doc(giftId)
        .delete();
  }

  Future<List<WishModel>> getMyPledgedGifts() async {
    final myPledgedGifts =
        await _firestore
            .collection("Store Data")
            .doc(uid)
            .collection("myPledgedGifts")
            .get();
    return myPledgedGifts.docs
        .map((doc) => WishModel.fromJson(doc.data()))
        .toList();
  }

  // Add this method to update user information
  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Update in Firestore
      await _firestore
          .collection("Store Data")
          .doc(user.uid)
          .update(user.toJson());

      // Update in Hive
      await HiveService.saveUser(user);
    } catch (e) {
      developer.log(
        'Error updating user profile: $e',
        name: 'FirestoreService',
        error: e,
      );
      throw e;
    }
  }

  Future<void> updateFriendReference(String friendUid, UserModel user) async {
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("friends")
        .doc(user.uid)
        .update(user.toJson());
  }
}
