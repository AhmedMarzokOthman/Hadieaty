import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/cubits/event/event_cubit.dart';
import 'package:hadieaty/cubits/friend/friend_cubit.dart';
import 'package:hadieaty/cubits/home/home_cubit.dart';
import 'package:hadieaty/cubits/pledge/pledge_cubit.dart';
import 'package:hadieaty/cubits/profile/profile_cubit.dart';
import 'package:hadieaty/cubits/wish/wish_cubit.dart';
import 'package:hadieaty/firebase_options.dart';
import 'package:hadieaty/views/events_page.dart';
import 'package:hadieaty/views/friend_details_page.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/views/my_wishes_page.dart';
import 'package:hadieaty/views/pledged_gifts_page.dart';
import 'package:hadieaty/views/profile_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';
import 'package:hadieaty/views/splash_page.dart';
import 'package:hadieaty/services/hive_service.dart';
import 'package:hadieaty/utils/app_routes.dart';

void main() async {
  // Catch any errors during initialization
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Add error handling for orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Initialize services with error handling
      try {
        await HiveService.init();
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        log('Firebase initialized successfully', name: 'App');
      } catch (e) {
        log('Error during initialization: $e', name: 'App', error: e);
      }

      runApp(const App());
    },
    (error, stack) {
      log(
        'Uncaught error: $error',
        name: 'Global',
        error: error,
        stackTrace: stack,
      );
    },
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        BlocProvider<EventCubit>(create: (context) => EventCubit()),
        BlocProvider<WishCubit>(create: (context) => WishCubit()),
        BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
        BlocProvider<PledgeCubit>(create: (context) => PledgeCubit()),
        BlocProvider<FriendCubit>(create: (context) => FriendCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Manrope",
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontFamily: 'Manrope'),
          ),
        ),
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
      ),
    );
  }
}
