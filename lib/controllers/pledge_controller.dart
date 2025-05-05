import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/models/wish_model.dart';

class PledgeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated in Firestore service');
    }
    return user.uid;
  }

    Future<void> pledgeGift(String friendUid, WishModel gift) async {
    final currentUser = await UserController().getUser();
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("wishes")
        .doc(gift.id)
        .update({
          "pledgedBy": {"pldgerUid": uid, "pldgerName": currentUser.name},
        });

    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("myPledgedGifts")
        .doc(gift.id)
        .set({"gift": gift.toJson(), "friendUid": friendUid});
  }

  Future<void> unpledgeGift(String friendUid, String giftId) async {
    await _firestore
        .collection("Store Data")
        .doc(friendUid)
        .collection("wishes")
        .doc(giftId)
        .update({"pledgedBy": null});

    await _firestore
        .collection("Store Data")
        .doc(uid)
        .collection("myPledgedGifts")
        .doc(giftId)
        .delete();
  }

  Future<List<WishModel>> getMyPledgedGifts() async {
    final myPledgedGifts =
        await _firestore
            .collection("Store Data")
            .doc(uid)
            .collection("myPledgedGifts")
            .get();
    return myPledgedGifts.docs
        .map((doc) => WishModel.fromJson(doc.data()))
        .toList();
  }
}
