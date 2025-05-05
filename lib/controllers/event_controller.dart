import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hive/hive.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firestore service');
    }
    return user.uid;
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

  Future<void> saveEventToLocal(EventModel event) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.put(event.id, event);
  }

  Future<EventModel?> getEventFromLocal(String id) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    return box.get(id);
  }

  Future<void> deleteEventFromLocal(String id) async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.delete(id);
  }

  Future<void> deleteAllEventsFromLocal() async {
    final box = await Hive.openBox<EventModel>('eventBox');
    await box.clear();
  }
}
