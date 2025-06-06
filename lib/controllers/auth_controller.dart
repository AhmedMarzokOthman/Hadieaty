import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hadieaty/controllers/event_controller.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/controllers/wish_controller.dart';
import 'package:hadieaty/models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String createUsername(String name) {
    // Convert to lowercase and replace spaces with underscores
    String username = name.toLowerCase().replaceAll(" ", "_");

    // Generate a random 4-digit number
    int randomNum = DateTime.now().millisecondsSinceEpoch % 10000;

    // Pad with leading zeros if needed to ensure 4 digits
    String fourDigitNum = randomNum.toString().padLeft(4, '0');

    // Add the 4-digit number to make it unique
    username = "${username}_$fourDigitNum";

    return username;
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // print('\x1B[34mGoogle User: ${googleUser.toString()}\x1B[0m');
      if (googleUser == null) {
        return {"statusCode": 400, "data": "Sign-in cancelled"};
      }
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      // print('\x1B[33mGoogle Auth: ${googleAuth.toString()}\x1B[0m');
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // print('\x1B[36mCredential: ${credential.toString()}\x1B[0m');
      UserCredential user = await _auth.signInWithCredential(credential);

      // print('\x1B[32mUser: ${user.user}\x1B[0m');

      if (user.user == null) {
        return {"data": "Failed to sign in with Google", "statusCode": 400};
      }

      UserModel userData = UserModel(
        uid: user.user!.uid,
        name: user.user!.displayName!,
        username: createUsername(user.user!.displayName!),
        email: user.user!.email!,
        profilePicture: user.user!.photoURL!,
      );

      final userExistsRes = await UserController().userExists();
      if (userExistsRes["exists"] == false) {
        await UserController().saveUserToLocal(userData);
        await UserController().addUser(userData);
      } else {
        final user = UserModel.fromJson(userExistsRes["data"]);
        final wishes = await WishController().getWishes();
        final events = await EventController().getEvents();
        final friends = await UserController().getFriends();
        await UserController().saveUserToLocal(user);
        for (var wish in wishes) {
          await WishController().saveWishToLocal(wish);
        }
        for (var event in events) {
          await EventController().saveEventToLocal(event);
        }
        for (var friend in friends) {
          await UserController().saveFriendToLocal(friend);
        }
      }

      return {"data": user.user, "statusCode": 200};
    } catch (e) {
      return {"data": e.toString(), "statusCode": 400};
    }
  }

  Future<Map<String, dynamic>> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;

      // Sign out
      await _auth.signOut();
      await GoogleSignIn().signOut();

      // Clean up local storage
      if (uid != null) {
        await UserController().deleteUserFromLocal(uid);
        await WishController().deleteAllWishesFromLocal();
        await EventController().deleteAllEventsFromLocal();
        await UserController().deleteAllFriendsFromLocal();
      }

      return {"data": "Signed out successfully", "statusCode": 200};
    } catch (e) {
      return {"data": e.toString(), "statusCode": 400};
    }
  }
}
