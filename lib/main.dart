import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hadieaty/firebase_options.dart';
import 'package:hadieaty/views/events_page.dart';
import 'package:hadieaty/views/friend_details_page.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/profile_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';
import 'package:hadieaty/views/splash_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/services/hive_service.dart';
import 'package:hadieaty/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Manrope"),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.home: (context) => HomePage(),
        AppRoutes.events: (context) => EventsPage(),
        AppRoutes.friendDetails: (context) => FriendDetailsPage(),
        AppRoutes.profile: (context) => ProfilePage(),
        AppRoutes.signIn: (context) => SignInPage(),
        AppRoutes.splash: (context) => SplashPage(),
        AppRoutes.myWishes: (context) => MyWishesPage(),
        AppRoutes.pledgedGifts: (context) => PledgedGiftsPage(),
      },
    );
  }
}
