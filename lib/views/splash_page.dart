import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/constants/colors.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/cubits/auth/auth_state.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/views/sign-in.page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _timeoutOccurred = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    // Set a timeout to ensure we don't get stuck on splash screen
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _timeoutOccurred = true;
        });
      }
    });

    // Delay slightly to ensure cubits are properly initialized
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<AuthCubit>().checkAndRedirectUser();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!state.isLoading) {
          _timeoutTimer?.cancel();

          if (state.userExists) {
            // User exists, go to Home
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else {
            // User does not exist, go to SignIn
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFAB5D), primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo or Brand
                  Text(
                    "Hadieaty",
                    style: TextStyle(
                      fontFamily: "FREESCPT",
                      fontSize: 72,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Show loading or timeout message
                  if (_timeoutOccurred)
                    Column(
                      children: [
                        Text(
                          "Taking longer than expected",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _timeoutOccurred = false;
                            });
                            context.read<AuthCubit>().checkAndRedirectUser();

                            // Reset timeout
                            _timeoutTimer?.cancel();
                            _timeoutTimer = Timer(
                              const Duration(seconds: 8),
                              () {
                                if (mounted) {
                                  setState(() {
                                    _timeoutOccurred = true;
                                  });
                                }
                              },
                            );
                          },
                          child: Text("Try Again"),
                        ),
                      ],
                    )
                  else
                    CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
