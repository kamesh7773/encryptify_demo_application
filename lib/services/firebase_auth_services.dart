import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encryptify/encryptify.dart';
import '../pages/home_page.dart';
import '../pages/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthMethod {
  // Variables related to Firebase instances
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  // ----------------------------
  // Email Authentication Methods
  // ----------------------------

  //! Email & Password Sign-Up Method
  static Future<void> signUpWithEmail({
    required String fullName,
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

      //* 1st step By using the generateKeys() method we generate the RSA Public and Private Key's and AES Key and IV.
      await Encryptify.generateKeys();

      //* 2nd step By using the returnKeys() method we get the RSA Key Pairs and AES Key and IV.
      final keyData = await Encryptify.returnKeys();

      //* 3rd step creating the user account on firebase using email & password
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      //* 4th step By using the Encryptify Package we encrypt the RSA Private Key, AES Key and IV of current user using the creationTime (creationTime usead as custom String for encryption).
      //* (if you are using the Google OAuth Provider then you can use the sub/id string from userCredentail Data or if you are using the FB Auth then you can use the ID string from userCredentail Data).
      final encryptedData = await Encryptify.encryptionWithCustomString(customString: _auth.currentUser!.metadata.creationTime.toString());

      //* 5th step seting the current user info to firestore database collection.
      await _firestoreDB.collection("users").doc(_auth.currentUser!.uid).set({
        "userID": _auth.currentUser!.uid,
        "name": fullName,
        "email": email,
        "provider": "Email & Password",
        "rsaPublicKey": keyData.rsaPublicKey,
        "encryptedRsaPrivateKey": encryptedData.encryptedRsaPrivateKey,
        "encryptedAESKey": encryptedData.encryptedAesKey,
        "encryptedIV": encryptedData.encryptedIv,
      });

      // retriving the other user ID
      final QuerySnapshot querySnapshot = await _firestoreDB.collection('users').where('userID', isNotEqualTo: _auth.currentUser!.uid).get();
      final otherUserId = querySnapshot.docs[0]["userID"];

      // Redirect to HomePage after successful account creation
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePage(
              otherUserId: otherUserId,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
    // Handle Firebase Auth exceptions during account creation
    on FirebaseAuthException catch (error) {
      if (error.message == "A network error (such as timeout, interrupted connection or unreachable host) has occurred." && context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection failed. Please check your network connection and try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (context.mounted) {
          Navigator.of(context).pop();
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
            canPop: true,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

      //* 1st step we sign in the user to firebase using email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      //* 2nd step we fetch the user data from firestore database collection
      final userDoc = await _firestoreDB.collection("users").doc(_auth.currentUser!.uid).get();

      //* 3rd step we decrypt the RSA Private Key, AES Key and IV using the creationTime (custom String).
      //* (this decryptionWithCustomString method also update the RSA Private Key, AES Key and IV in the Encryptify class).
      await Encryptify.decryptionWithCustomString(
        pemRSAPublicKey: userDoc["rsaPublicKey"],
        encryptedRsaPrivateKey: userDoc["encryptedRsaPrivateKey"],
        encryptedAesKey: userDoc["encryptedAESKey"],
        encryptedIv: userDoc["encryptedIV"],
        customString: _auth.currentUser!.metadata.creationTime.toString(),
      );

      // retriving the other user ID
      final QuerySnapshot querySnapshot = await _firestoreDB.collection('users').where('userID', isNotEqualTo: _auth.currentUser!.uid).get();
      final otherUserId = querySnapshot.docs[0]["userID"];

      // Redirect to HomePage after successful account creation
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePage(
              otherUserId: otherUserId,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    }
    // Handling Login auth Exceptions
    on FirebaseAuthException catch (error) {
      if (error.code == "A network error (such as timeout, interrupted connection or unreachable ) has occurred." && context.mounted) {
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

      //* deleting the RSA Private Key, AES Key and IV from the Encryptify class
      await Encryptify.flushKeys();

      // After SignOut redirecting user to LoginPage
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SignInPage(),
          ),
          (Route<dynamic> route) => false,
        );
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
