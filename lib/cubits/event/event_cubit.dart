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
      final events = await _eventController.getEvents();
      for (var event in events) {
        await _eventController.saveEventToLocal(event);
      }
      emit(state.copyWith(isLoading: false, events: events));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addEvent(EventModel event) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _eventController.addEvent(event);
      await _eventController.saveEventToLocal(event);
      await loadEvents();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateEvent(EventModel event) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _eventController.addEvent(event); // Same as update
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
