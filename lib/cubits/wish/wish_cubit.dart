import 'package:bloc/bloc.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/cubits/wish/wish_state.dart';
import 'package:hadieaty/models/wish_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WishCubit extends Cubit<WishState> {
  final WishController _wishController = WishController();

  WishCubit() : super(WishState()) {
    loadWishes();
  }

  Future<void> loadWishes() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final wishes = await _wishController.getWishes();
      for (var wish in wishes) {
        await _wishController.saveWishToLocal(wish);
      }
      emit(state.copyWith(isLoading: false, wishes: wishes));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addWish(WishModel wish) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _wishController.addWish(wish);
      await _wishController.saveWishToLocal(wish);
      await loadWishes();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> editWish(WishModel wish) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _wishController.editWish(wish);
      await _wishController.saveWishToLocal(wish);
      await loadWishes();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteWish(String id) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _wishController.deleteWish(id);
      await _wishController.deleteWishFromLocal(id);
      await loadWishes();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<Box<WishModel>> openWishBox() async {
    return await Hive.openBox<WishModel>('wishBox');
  }
}
