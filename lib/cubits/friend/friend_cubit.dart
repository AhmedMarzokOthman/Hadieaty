import 'package:bloc/bloc.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/pledge_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/cubits/friend/friend_state.dart';
import 'package:hadieaty/models/event_model.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/models/wish_model.dart';

class FriendCubit extends Cubit<FriendState> {
  final WishController _wishController = WishController();
  final EventController _eventController = EventController();
  final PledgeController _pledgeController = PledgeController();

  FriendCubit({UserModel? friend}) : super(FriendState(friend: friend)) {
    if (friend != null) {
      loadFriendData(friend);
    }
  }

  void setFriend(UserModel friend) {
    emit(state.copyWith(friend: friend));
    loadFriendData(friend);
  }

  Future<void> loadFriendData(UserModel friend) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final wishes = await _wishController.getFriendWishes(friend.uid);
      final events = await _eventController.getFriendEvents(friend.uid);

      emit(state.copyWith(isLoading: false, wishes: wishes, events: events));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> pledgeGift(WishModel wish) async {
    if (state.friend == null) return;

    // First, update the local state with an optimistic update
    final updatedWishes = List<WishModel>.from(state.wishes);
    final wishIndex = updatedWishes.indexWhere((w) => w.id == wish.id);

    if (wishIndex != -1) {
      updatedWishes[wishIndex] = wish.copyWith(
        pledgedBy: {
          "pldgerUid": _pledgeController.uid,
          "pldgerName": "Me", // This will be updated on the server anyway
        },
      );
      emit(state.copyWith(wishes: updatedWishes));
    }

    try {
      // Then make the actual API call
      await _pledgeController.pledgeGift(state.friend!.uid, wish);

      // Only reload the data if something went wrong with our optimistic update
      if (wishIndex == -1) {
        await loadFriendData(state.friend!);
      }
    } catch (e) {
      // If the API call fails, revert our optimistic update and show error
      if (wishIndex != -1) {
        updatedWishes[wishIndex] = wish;
        emit(state.copyWith(wishes: updatedWishes, error: e.toString()));
      } else {
        emit(state.copyWith(error: e.toString()));
      }
    }
  }

  Future<void> unpledgeGift(String giftId) async {
    if (state.friend == null) return;

    // First, update the local state with an optimistic update
    final updatedWishes = List<WishModel>.from(state.wishes);
    final wishIndex = updatedWishes.indexWhere((w) => w.id == giftId);

    // Store the original wish in case we need to revert
    WishModel? originalWish;

    if (wishIndex != -1) {
      originalWish = updatedWishes[wishIndex];
      updatedWishes[wishIndex] = originalWish.copyWith(pledgedBy: null);
      emit(state.copyWith(wishes: updatedWishes));
    }

    try {
      // Then make the actual API call
      await _pledgeController.unpledgeGift(state.friend!.uid, giftId);

      // Only reload if our optimistic update didn't work
      if (wishIndex == -1) {
        await loadFriendData(state.friend!);
      }
    } catch (e) {
      // If the API call fails, revert our optimistic update and show error
      if (wishIndex != -1 && originalWish != null) {
        updatedWishes[wishIndex] = originalWish;
        emit(state.copyWith(wishes: updatedWishes, error: e.toString()));
      } else {
        emit(state.copyWith(error: e.toString()));
      }
    }
  }

  Future<String> getEventName(String? eventId) async {
    if (eventId == null || eventId.isEmpty) {
      return '';
    }

    // Check cache
    if (state.eventNamesCache.containsKey(eventId)) {
      return state.eventNamesCache[eventId]!;
    }

    try {
      final event = await _eventController.getEventFromLocal(eventId);
      if (event != null) {
        // Update cache
        final updatedCache = Map<String, String>.from(state.eventNamesCache);
        updatedCache[eventId] = event.name;
        emit(state.copyWith(eventNamesCache: updatedCache));
        return event.name;
      }

      if (state.friend != null) {
        final events = await _eventController.getFriendEvents(
          state.friend!.uid,
        );
        final matchingEvent = events.firstWhere(
          (e) => e.id == eventId,
          orElse:
              () => EventModel(
                id: '',
                name: 'Unknown Event',
                type: '',
                date: DateTime.now(),
              ),
        );

        // Update cache
        final updatedCache = Map<String, String>.from(state.eventNamesCache);
        updatedCache[eventId] = matchingEvent.name;
        emit(state.copyWith(eventNamesCache: updatedCache));

        return matchingEvent.name;
      }

      return 'Unknown Event';
    } catch (e) {
      return 'Unknown Event';
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(activeTabIndex: index));
  }

  Future<void> loadUpcomingEventsCount(String friendUid) async {
    if (friendUid.isEmpty) return;

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

      emit(state.copyWith(upcomingEventsCount: upcomingEvents.length));
    } catch (e) {
      // Don't update state on error, just keep the current count
    }
  }

  Future<void> loadEventWishes(String eventId) async {
    if (eventId.isEmpty) return;

    emit(state.copyWith(isLoadingEventWishes: true));
    try {
      // Get all user wishes
      final wishes = await _wishController.getWishes();

      // Filter wishes that are associated with this event
      final eventWishes =
          wishes.where((wish) => wish.associatedEvent == eventId).toList();

      emit(
        state.copyWith(eventWishes: eventWishes, isLoadingEventWishes: false),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingEventWishes: false));
    }
  }
}
