import 'package:flutter/material.dart';
import 'package:hadieaty/views/home_page.dart';
import 'package:hadieaty/controllers/auth_controller.dart';

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
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.only(left: 50, right: 50, top: 20),
            child: ElevatedButton(
              onPressed: () async {
                final value = await AuthController().signInWithGoogle();
                if (value["statusCode"] == 200) {
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(value["data"])));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: EdgeInsets.all(10),
                foregroundColor: Colors.grey,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/imgs/google_icon.png",
                    width: 25,
                    height: 25,
                  ),
                  SizedBox(width: 15),
                  Text(
                    "Continue with Google",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
