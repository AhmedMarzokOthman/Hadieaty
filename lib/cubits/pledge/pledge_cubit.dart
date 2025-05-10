import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hadieaty/controllers/pledge_controller.dart';
import 'package:hadieaty/cubits/pledge/pledge_state.dart';
import 'package:hadieaty/models/wish_model.dart';

class PledgeCubit extends Cubit<PledgeState> {
  final PledgeController _pledgeController = PledgeController();

  PledgeCubit() : super(PledgeState()) {
    loadPledgedGifts();
  }

  Future<void> loadPledgedGifts() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final pledgedGifts = await _getPledgedGiftsWithDetails();
      emit(state.copyWith(isLoading: false, pledgedGifts: pledgedGifts));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> pledgeGift(String friendUid, WishModel wish) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _pledgeController.pledgeGift(friendUid, wish);
      await loadPledgedGifts();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> unpledgeGift(String friendUid, String giftId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _pledgeController.unpledgeGift(friendUid, giftId);
      await loadPledgedGifts();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<Map<String, dynamic>>> _getPledgedGiftsWithDetails() async {
    try {
      // Get the pledged gifts collection data
      final snapshot =
          await FirebaseFirestore.instance
              .collection("Store Data")
              .doc(_pledgeController.uid)
              .collection("myPledgedGifts")
              .get();

      List<Map<String, dynamic>> result = [];

      // Process each document
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final gift = WishModel.fromJson(data['gift']);
        final friendUid = data['friendUid'] as String;

        // Get friend details
        final friendDoc =
            await FirebaseFirestore.instance
                .collection("Store Data")
                .doc(friendUid)
                .get();

        final friendData = friendDoc.data() ?? {};
        final friendName = friendData['name'] ?? 'Unknown';

        result.add({
          'wish': gift,
          'friendUid': friendUid,
          'friendName': friendName,
        });
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
