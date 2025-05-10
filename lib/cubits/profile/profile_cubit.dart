import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/cubits/profile/profile_state.dart';
import 'package:hadieaty/models/user_model.dart';
import 'package:hadieaty/models/wish_model.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserController _userController = UserController();
  final EventController _eventController = EventController();
  final WishController _wishController = WishController();

  ProfileCubit() : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final user = await _userController.getUserFromLocal(uid);

      final events = await _eventController.getEvents();
      events.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Sort by date (newest first)

      emit(state.copyWith(isLoading: false, user: user, events: events));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadEventWishes(String eventId) async {
    try {
      // Create a map if it doesn't exist yet
      final Map<String, List<WishModel>> updatedEventWishes =
          Map<String, List<WishModel>>.from(state.eventWishes);

      // Load event wishes only if we haven't loaded them already
      if (!updatedEventWishes.containsKey(eventId)) {
        emit(state.copyWith(isLoadingEventWishes: true));

        // Get all user wishes
        final wishes = await _wishController.getWishes();

        // Filter wishes that are associated with this event
        final eventWishes =
            wishes.where((wish) => wish.associatedEvent == eventId).toList();

        // Update the map with this event's wishes
        updatedEventWishes[eventId] = eventWishes;

        emit(
          state.copyWith(
            eventWishes: updatedEventWishes,
            isLoadingEventWishes: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingEventWishes: false));
    }
  }

  Future<void> updateProfile(UserModel user) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _userController.saveUserToLocal(user);
      await _userController.updateUserProfile(user);

      // Update in friends collections
      final friends = await _userController.getFriends();
      for (final friend in friends) {
        try {
          await _userController.updateFriendReference(friend.uid, user);
        } catch (e) {
          // Handle error
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          user: user,
          refreshToggle: !state.refreshToggle, // Toggle to force rebuild
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
