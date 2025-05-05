import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
import 'package:project_abiyahe/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userDetails;
  String? _currentUserId;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  late Stream<QuerySnapshot> _userStream;
  late FirebaseUserAPI firebaseService;

  UserProvider() {
    firebaseService = FirebaseUserAPI();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _currentUserId = _auth.currentUser?.uid;
    if (_currentUserId != null) {
      await getUserDetails(_currentUserId!);
    }
    notifyListeners();
  }

  // getters
  Stream<QuerySnapshot> get user => _userStream;
  Map<String, dynamic>? get userDetails => _userDetails;
  String? get currentUserId => _currentUserId;
  
  Future<String?> getCurrentUserId() async {
    if (_currentUserId == null) {
      _currentUserId = _auth.currentUser?.uid;
      if (_currentUserId != null) {
        await getUserDetails(_currentUserId!);
      }
      notifyListeners();
    }
    return _currentUserId;
  }

  Future<void> updateUserDetails(Map<String, dynamic> userData) async {
    _userDetails = userData;
    _currentUserId = userData['userId'];
    notifyListeners();
  }

  Future<void> editUser({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? userName,
    String? profilePictureUrl,
    List<String>? interests,
    List<String>? travelPreferences,
  }) async {
    try {
      final uid = await getCurrentUserId();
      if (uid == null) {
        throw Exception('User not logged in');
      }

      // Get current user details
      final currentDetails = await firebaseService.getUserDetails(uid);
      if (currentDetails == null) {
        throw Exception('User not found for id: $uid');
      }

      // use old value if new one is null
      String updatedFirstName = firstName ?? currentDetails['firstName'] ?? '';
      String updatedLastName = lastName ?? currentDetails['lastName'] ?? '';
      String updatedEmail = email ?? currentDetails['email'] ?? '';
      String updatedPhoneNumber = phoneNumber ?? currentDetails['phoneNumber'] ?? '';
      String updatedUserName = userName ?? currentDetails['userName'] ?? '';
      String updatedProfilePictureUrl = profilePictureUrl ?? currentDetails['profilePictureUrl'] ?? '';
      List<String> updatedInterests = interests ?? List<String>.from(currentDetails['interests'] ?? []);
      List<String> updatedTravelPreferences = travelPreferences ?? List<String>.from(currentDetails['travelPreferences'] ?? []);

      //store the values
      String message = await firebaseService.editUser(
        uid: uid,
        firstName: updatedFirstName,
        lastName: updatedLastName,
        email: updatedEmail,
        phoneNumber: updatedPhoneNumber,
        userName: updatedUserName,
        profilePictureUrl: updatedProfilePictureUrl,
        interests: updatedInterests,
        travelPreferences: updatedTravelPreferences,
      );

      print(message);
      notifyListeners();
    } catch (e) {
      print("Error editing user: $e");
      rethrow;
    }
  }

  Future<void> getUserDetails(String uid) async {
    try {
      _userDetails = await firebaseService.getUserDetails(uid);
      notifyListeners();
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }
} 