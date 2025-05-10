import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/cubits/home/home_state.dart';
import 'package:hadieaty/models/user_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final UserController _userController = UserController();

  HomeCubit() : super(HomeState()) {
    initialize();
  }

  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final user = await _userController.getUserFromLocal(uid);

      await loadFriends();

      emit(state.copyWith(isLoading: false, isInitialized: true, user: user));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadFriends() async {
    try {
      final friends = await _userController.getFriends();
      for (var friend in friends) {
        await _userController.saveFriendToLocal(friend);
      }

      final localFriends = await _userController.getFriendsFromLocal();

      emit(state.copyWith(friends: localFriends));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void changeTab(int index) {
    emit(state.copyWith(activeIndex: index));
  }

  Future<void> addFriend(String username) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _userController.addFriend(username);
      await loadFriends();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  List<UserModel> getFriends() {
    return state.friends;
  }
}
