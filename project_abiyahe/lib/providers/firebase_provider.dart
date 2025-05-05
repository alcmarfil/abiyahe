import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TravelProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  TravelProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signup({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String password,
    List<String>? interests,
    List<String>? travelPreferences,
  }) async {
    try {
      final checkUser =
          await _firestore
              .collection("Users")
              .where("userName", isEqualTo: userName)
              .limit(1)
              .get();
      if (checkUser.docs.isNotEmpty) {
        return 'Username already exists';
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      //print('User created with UID: ${_user?.uid}');
      if (_user != null) {
        await _firestore.collection("Users").doc(_user!.uid).set({
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "userName": userName,
          "userId": _user!.uid,
          // "interests": interests ?? [],
          // "travelPreferences": travelPreferences ?? [],
        });
        // print('User data saved to Firestore');
      }
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    bool useUsername = false,
  }) async {
    try {
      String loginChoice = email;
      if (useUsername) {
        final userSnapshot =
            await _firestore
                .collection("Users")
                .where("userName", isEqualTo: email)
                .get();
        if (userSnapshot.docs.isNotEmpty) {
          loginChoice = userSnapshot.docs.first["email"];
        } else {
          return 'User not found';
        }
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: loginChoice,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Incorect email';
      } else {
        return e.message;
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  bool get isSignedIn => _user != null;
  String? get userId => _user?.uid;
}
