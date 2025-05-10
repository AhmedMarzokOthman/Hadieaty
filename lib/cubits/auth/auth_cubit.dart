import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:hadieaty/controllers/auth_controller.dart';
import 'package:hadieaty/cubits/auth/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/controllers/user_controller.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();

  AuthCubit() : super(AuthState());

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _authController.signInWithGoogle();
      if (response["statusCode"] == 200) {
        emit(
          state.copyWith(
            isAuthenticated: true,
            isLoading: false,
            user: response["data"],
          ),
        );
      } else {
        emit(
          state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            error: response["data"],
          ),
        );
      }
    } catch (e) {
      log('Error during Google sign-in: $e', name: 'AuthCubit', error: e);
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _authController.signOut();
      if (response["statusCode"] == 200) {
        emit(AuthState()); // Reset to initial state
      } else {
        emit(state.copyWith(isLoading: false, error: response["data"]));
      }
    } catch (e) {
      log('Error during sign-out: $e', name: 'AuthCubit', error: e);
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> checkAndRedirectUser() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      // Check if Firebase Auth is initialized
      if (FirebaseAuth.instance == null) {
        log('Firebase Auth is not initialized', name: 'AuthCubit');
        emit(
          state.copyWith(
            isLoading: false,
            userExists: false,
            error: 'Firebase Auth not initialized',
          ),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('No current user found', name: 'AuthCubit');
        emit(state.copyWith(isLoading: false, userExists: false));
        return;
      }

      // Check if user exists in local storage
      try {
        final userExists = await _userController.userExistsInLocal(user.uid);
        log('User exists in local: $userExists', name: 'AuthCubit');
        emit(state.copyWith(isLoading: false, userExists: userExists));
      } catch (localError) {
        // If local check fails, try to continue with Firebase
        log(
          'Error checking local user: $localError',
          name: 'AuthCubit',
          error: localError,
        );

        try {
          // Fall back to checking Firestore
          final firestoreResult = await _userController.userExists();
          final exists = firestoreResult["exists"] ?? false;
          log('User exists in Firestore: $exists', name: 'AuthCubit');

          emit(state.copyWith(isLoading: false, userExists: exists));
        } catch (firestoreError) {
          // If everything fails, go to sign in
          log(
            'Error checking Firestore: $firestoreError',
            name: 'AuthCubit',
            error: firestoreError,
          );
          emit(state.copyWith(isLoading: false, userExists: false));
        }
      }
    } catch (e) {
      log('Error checking user: $e', name: 'AuthCubit', error: e);
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          userExists: false,
        ),
      );
    }
  }
}
