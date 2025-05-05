import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/controllers/user_controller.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkUser(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          // User exists, go to Home
          Future.microtask(() {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          });
        } else {
          // User does not exist, go to SignIn
          Future.microtask(() {
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const SignInPage()),
              );
            }
          });
        }
        // While navigating, show nothing
        return const SizedBox.shrink();
      },
    );
  }

  Future<bool> _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return await UserController().userExistsInLocal(user.uid);
  }
}
