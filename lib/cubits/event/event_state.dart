import 'package:hadieaty/models/event_model.dart';

class EventState {
  final bool isLoading;
  final List<EventModel> events;
  final String? error;
  final String sortBy;
  final bool sortAscending;
  final String filterStatus;

  EventState({
    this.isLoading = false,
    this.events = const [],
    this.error,
    this.sortBy = 'date',
    this.sortAscending = true,
    this.filterStatus = 'All',
  });

  EventState copyWith({
    bool? isLoading,
    List<EventModel>? events,
    String? error,
    String? sortBy,
    bool? sortAscending,
    String? filterStatus,
  }) {
    return EventState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  List<EventModel> getSortedAndFilteredEvents() {
    List<EventModel> filteredEvents = List.from(events);

    // Apply filter
    if (filterStatus != 'All') {
      filteredEvents =
          filteredEvents
              .where((event) => event.status == filterStatus)
              .toList();
    }

    // Apply sort
    filteredEvents.sort((a, b) {
      int result;

      switch (sortBy) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'type':
          result = a.type.compareTo(b.type);
          break;
        case 'date':
        default:
          result = a.date.compareTo(b.date);
          break;
      }

      return sortAscending ? result : -result;
    });

    return filteredEvents;
  }
}
