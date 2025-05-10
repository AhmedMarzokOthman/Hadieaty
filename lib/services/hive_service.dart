import 'dart:developer';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter/foundation.dart';

class HiveService {
  static Future<void> init() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(WishModelAdapter());
      }

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(EventModelAdapter());
      }

      log('Hive initialized successfully', name: 'HiveService');
    } catch (e, stackTrace) {
      log('Error initializing Hive: $e', name: 'HiveService', error: e);
      if (kDebugMode) {
        print('Hive initialization error: $e');
        print('Stack trace: $stackTrace');
      }
      // Continue execution even if Hive fails
    }
  }
}
