import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class Authentication {
  static Future<FirebaseApp> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    return firebaseApp;
  }

  static SnackBar customSnackBar({String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}

class AppleSignInAvailable {
  AppleSignInAvailable(this.isAvailable);
  final bool isAvailable;

  static Future<AppleSignInAvailable> check() async {
    return AppleSignInAvailable(await TheAppleSignIn.isAvailable());
  }
}
