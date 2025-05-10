import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/cubits/event/event_state.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EventCubit extends Cubit<EventState> {
  final EventController _eventController = EventController();

  EventCubit() : super(EventState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Get events from Firebase
      final events = await _eventController.getEvents();

      // Update local storage with latest events
      for (var event in events) {
        log(event.name.toString());
        await _eventController.saveEventToLocal(event);
      }

      // Emit new state with updated events
      emit(state.copyWith(isLoading: false, events: events, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addEvent(EventModel event) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      log('Adding event: ${event.name}');

      // First add to Firebase
      await _eventController.addEvent(event);
      log('Event added to Firebase');

      // Then update local storage
      await _eventController.saveEventToLocal(event);
      log('Event added to local storage');

      // Reload all events to update the UI
      await loadEvents();
      log('Events reloaded, UI should update');
    } catch (e) {
      log('Error adding event: $e');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateEvent(EventModel event) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _eventController.editEvent(event);
      await _eventController.saveEventToLocal(event);
      await loadEvents();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteEvent(String id) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _eventController.deleteEvent(id);
      await _eventController.deleteEventFromLocal(id);
      await loadEvents();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void setSortBy(String sortBy) {
    final currentSortBy = state.sortBy;
    final currentSortAscending = state.sortAscending;

    if (currentSortBy == sortBy) {
      emit(state.copyWith(sortAscending: !currentSortAscending));
    } else {
      emit(state.copyWith(sortBy: sortBy, sortAscending: true));
    }
  }

  void setFilterStatus(String filterStatus) {
    emit(state.copyWith(filterStatus: filterStatus));
  }

  Future<Box<EventModel>> openEventBox() async {
    return await Hive.openBox<EventModel>('eventBox');
  }
}
