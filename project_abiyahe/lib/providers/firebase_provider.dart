import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';

class TravelProvider extends ChangeNotifier {
  final FirebaseUserAPI _userApi = FirebaseUserAPI();

  User? _user;
  User? get user => _user;

  TravelProvider() {
    _userApi.authStateChanges().listen((user) {
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
    final result = await _userApi.signUp(
      firstName: firstName,
      lastName: lastName,
      userName: userName,
      email: email,
      password: password,
      interests: interests,
      travelPreferences: travelPreferences,
    );

    // Update _user if sign up was successful
    _user = _userApi.currentUser;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await _userApi.getUserData();
  }

  Future<String?> login({
    required String email,
    required String password,
    bool useUsername = false,
  }) async {
    final result = await _userApi.login(
      email: email,
      password: password,
      useUsername: useUsername,
    );
    _user = _userApi.currentUser;
    notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    await _userApi.signOut();
    _user = null;
    notifyListeners();
  }

  bool get isSignedIn => _user != null;
  String? get userId => _user?.uid;
}
