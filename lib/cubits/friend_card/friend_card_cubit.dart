import 'package:bloc/bloc.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/cubits/friend_card/friend_card_state.dart';

class FriendCardCubit extends Cubit<FriendCardState> {
  final EventController _eventController = EventController();

  FriendCardCubit() : super(FriendCardState());

  Future<void> loadUpcomingEventsCount(String friendUid) async {
    if (friendUid.isEmpty) return;

    emit(state.copyWith(isLoading: true));
    try {
      final allEvents = await _eventController.getFriendEvents(friendUid);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Filter events to only include upcoming ones
      final upcomingEvents =
          allEvents.where((event) {
            final eventDate = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            return eventDate.isAfter(today) ||
                eventDate.isAtSameMomentAs(today);
          }).toList();

      emit(
        state.copyWith(
          isLoading: false,
          upcomingEventsCount: upcomingEvents.length,
          friendUid: friendUid,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
