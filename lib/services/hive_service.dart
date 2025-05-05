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
  }
}
