import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthMethod {
  // Variables related to Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------------------
  // Email Authentication Methods
  // ---------------------------

  //! Email & Password Login Method
  static Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // showing CircularProgressIndicator
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return PopScope(
            canPop: true, //! Set this to false once you debug your code.
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

      // Method for sing in user with email & password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // After login successfully redirecting user to HomePage
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, '/home_page');
      }
    }
    // Handling Login auth Exceptions
    on FirebaseAuthException catch (error) {
      if (error.message == "A network error (such as timeout, interrupted connection or unreachable ) has occurred." && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please turn on your Internet"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (error.message == "The supplied auth credential is incorrect, malformed or has expired." && context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invaild email or password"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ------------------------------------
  // Method related Firebase Auth SingOut
  // ------------------------------------

  //! Method for SingOut Firebase Provider auth account
  static Future<void> signOut({required BuildContext context}) async {
    try {
      // This method SignOut user from all firebase auth Provider's
      await _auth.signOut();

      // After SignOut redirecting user to LoginPage
      if (context.mounted) {
        Navigator.popAndPushNamed(context, '/login_page');
      }
    }
    //? Handling Error Related Google SignIn/SignUp.
    on FirebaseAuthException catch (error) {
      if (error.message == "A network error (such as timeout, interrupted connection or unreachable host) has occurred." && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please turn on your Internet")));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
