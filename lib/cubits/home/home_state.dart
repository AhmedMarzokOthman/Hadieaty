import 'package:hadieaty/models/user_model.dart';

class HomeState {
  final int activeIndex;
  final bool isLoading;
  final bool isInitialized;
  final UserModel? user;
  final List<UserModel> friends;
  final String? error;

  HomeState({
    this.activeIndex = 0,
    this.isLoading = false,
    this.isInitialized = false,
    this.user,
    this.friends = const [],
    this.error,
  });

  HomeState copyWith({
    int? activeIndex,
    bool? isLoading,
    bool? isInitialized,
    UserModel? user,
    List<UserModel>? friends,
    String? error,
  }) {
    return HomeState(
      activeIndex: activeIndex ?? this.activeIndex,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      user: user ?? this.user,
      friends: friends ?? this.friends,
      error: error ?? this.error,
    );
  }
}
