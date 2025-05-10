import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadieaty/cubits/auth/auth_cubit.dart';
import 'package:hadieaty/cubits/auth/auth_state.dart';
import 'package:hadieaty/views/home_page.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.8,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Image.asset("assets/imgs/logo_2.png", width: 100, height: 100),
            SizedBox(height: 20),
            Text(
              "Hadieaty",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "FREESCPT",
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFAB5D), Color(0xFFFB6938)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }

          if (state.isAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child:
                  state.isLoading
                      ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CircularProgressIndicator(
                          color: Color(0xFFFB6938),
                        ),
                      )
                      : Container(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.08,
                        child: ElevatedButton(
                          onPressed:
                              state.isLoading
                                  ? null
                                  : () =>
                                      context
                                          .read<AuthCubit>()
                                          .signInWithGoogle(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            foregroundColor: Colors.grey,
                          ),
                          child:
                              state.isLoading
                                  ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFB6938),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/imgs/google_icon.png",
                                        width: 25,
                                        height: 25,
                                      ),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            "Continue with Google",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 18,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}
