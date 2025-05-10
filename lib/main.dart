import 'dart:async';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/constants/colors.dart';
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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor2,
            primary: primaryColor2,
            secondary: const Color(0xFF03DAC6),
            tertiary: const Color(0xFFFF9E80),
            background: const Color(0xFFF8F9FD),
            surface: Colors.white,
            error: const Color(0xFFB00020),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onBackground: const Color(0xFF121212),
            onSurface: const Color(0xFF121212),
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: "Manrope",
              color: Color(0xFF121212),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            iconTheme: IconThemeData(color: Color(0xFF6C63FF)),
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),

          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor2, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor2, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFB00020), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFB00020), width: 2),
            ),
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
