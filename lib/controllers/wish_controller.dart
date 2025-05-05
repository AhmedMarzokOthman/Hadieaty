import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WishController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firestore service');
    }
    return user.uid;
  }

  Future<void> addWish(WishModel wish) async {
    try {
      final currentUid = uid;
      log(
        'Adding wish to Firestore for user: $currentUid, Wish ID: ${wish.id}',
        name: 'FirestoreService',
      );
      log('Wish data: ${wish.toJson()}', name: 'FirestoreService');

      await _firestore
          .collection("Store Data")
          .doc(currentUid)
          .collection("wishes")
          .doc(wish.id)
          .set(wish.toJson());

      log('Wish added successfully to Firestore', name: 'FirestoreService');
    } catch (e) {
      log(
        'Error adding wish to Firestore: $e',
        name: 'FirestoreService',
        error: e,
      );
    }
  }

  Future<void> editWish(WishModel wish) async {
    log('Editing wish in Firestore: ${wish.id}', name: 'FirestoreService');
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

  Future<void> saveWishToLocal(WishModel wish) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.put(wish.id, wish);
  }

  Future<WishModel?> getWishFromLocal(String id) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    return box.get(id);
  }

  Future<void> deleteWishFromLocal(String id) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.delete(id);
  }

  Future<void> deleteAllWishesFromLocal() async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.clear();
  }
}
