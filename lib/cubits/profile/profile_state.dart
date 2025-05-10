import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/models/wish_model.dart';

class ProfileState {
  final bool isLoading;
  final bool isLoadingEventWishes;
  final UserModel? user;
  final List<EventModel> events;
  final Map<String, List<WishModel>> eventWishes;
  final String? error;
  final bool refreshToggle;

  ProfileState({
    this.isLoading = false,
    this.isLoadingEventWishes = false,
    this.user,
    this.events = const [],
    this.eventWishes = const {},
    this.error,
    this.refreshToggle = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoadingEventWishes,
    UserModel? user,
    List<EventModel>? events,
    Map<String, List<WishModel>>? eventWishes,
    String? error,
    bool? refreshToggle,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingEventWishes: isLoadingEventWishes ?? this.isLoadingEventWishes,
      user: user ?? this.user,
      events: events ?? this.events,
      eventWishes: eventWishes ?? this.eventWishes,
      error: error ?? this.error,
      refreshToggle: refreshToggle ?? this.refreshToggle,
    );
  }
}
