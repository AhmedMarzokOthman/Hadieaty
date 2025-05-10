import 'package:hadieaty/models/wish_model.dart';

class WishState {
  final bool isLoading;
  final List<WishModel> wishes;
  final String? error;

  WishState({this.isLoading = false, this.wishes = const [], this.error});

  WishState copyWith({
    bool? isLoading,
    List<WishModel>? wishes,
    String? error,
  }) {
    return WishState(
      isLoading: isLoading ?? this.isLoading,
      wishes: wishes ?? this.wishes,
      error: error ?? this.error,
    );
  }
}
