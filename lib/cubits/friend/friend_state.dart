import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/models/wish_model.dart';

class FriendState {
  final bool isLoading;
  final bool isLoadingEventWishes;
  final UserModel? friend;
  final List<WishModel> wishes;
  final List<EventModel> events;
  final String? error;
  final Map<String, String> eventNamesCache;
  final int activeTabIndex;
  final int upcomingEventsCount;
  final List<WishModel> eventWishes;

  FriendState({
    this.isLoading = false,
    this.isLoadingEventWishes = false,
    this.friend,
    this.wishes = const [],
    this.events = const [],
    this.error,
    this.eventNamesCache = const {},
    this.activeTabIndex = 0,
    this.upcomingEventsCount = 0,
    this.eventWishes = const [],
  });

  FriendState copyWith({
    bool? isLoading,
    bool? isLoadingEventWishes,
    UserModel? friend,
    List<WishModel>? wishes,
    List<EventModel>? events,
    String? error,
    Map<String, String>? eventNamesCache,
    int? activeTabIndex,
    int? upcomingEventsCount,
    List<WishModel>? eventWishes,
  }) {
    return FriendState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingEventWishes: isLoadingEventWishes ?? this.isLoadingEventWishes,
      friend: friend ?? this.friend,
      wishes: wishes ?? this.wishes,
      events: events ?? this.events,
      error: error ?? this.error,
      eventNamesCache: eventNamesCache ?? this.eventNamesCache,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      upcomingEventsCount: upcomingEventsCount ?? this.upcomingEventsCount,
      eventWishes: eventWishes ?? this.eventWishes,
    );
  }
}
