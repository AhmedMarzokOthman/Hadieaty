import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hive_flutter/adapters.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(WishModelAdapter());
    Hive.registerAdapter(EventModelAdapter());
    await Hive.openBox<UserModel>('userBox');
  }

  static Future<void> saveUser(UserModel user) async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.put(user.uid, user);
  }

  static Future<UserModel?> getUser(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    // print('\x1B[32mUser: ${box.get(uid)}\x1B[0m');
    return box.get(uid);
  }

  static Future<void> deleteUser(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    await box.delete(uid);
  }

  static Future<bool> userExists(String uid) async {
    final box = await Hive.openBox<UserModel>('userBox');
    return box.containsKey(uid);
  }

  static Future<void> saveWish(WishModel wish) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.put(wish.id, wish);
  }

  static Future<WishModel?> getWish(String id) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    return box.get(id);
  }

  static Future<void> deleteWish(String id) async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.delete(id);
  }

  static Future<void> deleteAllWishes() async {
    final box = await Hive.openBox<WishModel>('wishBox');
    await box.clear();
  }

  static Future<void> saveEvent(EventModel event) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.put(event.id, event);
  }

  static Future<EventModel?> getEvent(String id) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    return box.get(id);
  }

  static Future<void> deleteEvent(String id) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.delete(id);
  }

  static Future<void> deleteAllEvents() async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.clear();
  }

  static Future<void> saveFriend(UserModel friend) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.put(friend.uid, friend);
  }

  static Future<UserModel?> getFriend(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.get(uid);
  }

  static Future<void> deleteFriend(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.delete(uid);
  }

  static Future<void> deleteAllFriends() async {
    final box = await Hive.openBox<UserModel>('friendBox');
    await box.clear();
  }

  static Future<bool> friendExists(String uid) async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.containsKey(uid);
  }

  static Future<List<UserModel>> getFriends() async {
    final box = await Hive.openBox<UserModel>('friendBox');
    return box.values.toList();
  }
}
