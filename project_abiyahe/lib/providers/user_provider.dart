import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
// import 'package:project_abiyahe/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  // User? _user;
  Map<String, dynamic>? _userDetails;
  List<String>? _friends;
  String? _currentUserId;
  String? _profileImageBase64;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Stream<QuerySnapshot> _userStream;
  late FirebaseUserAPI firebaseService;

  UserProvider() {
    firebaseService = FirebaseUserAPI();
    firebaseService.authStateChanges().listen((user) async {
      if (user != null) {
        _currentUserId = user.uid;
        await getUserDetails(_currentUserId!);
      } else {
        await clear();
      }
      notifyListeners();
    });
  }

  // getters
  Stream<QuerySnapshot> get user => _userStream;
  Map<String, dynamic>? get userDetails => _userDetails;
  String? get currentUserId => _currentUserId;
  String? get profileImageBase64 => _profileImageBase64;
  
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

  Future<void> clear() async {
    _userDetails = null;
    _currentUserId = null;
    _profileImageBase64 = null;
    _userStream = Stream.empty();
    notifyListeners();
  }

  // Future<void> signOut() async {
  //   await firebaseService.signOut();
  //   clear();
  // }

  Future<void> getFriends() async {
    final uid = await getCurrentUserId();
    if (uid == null) {
      throw Exception('User not logged in');
    }
    await firebaseService.canShareWithFriends(uid, _friends!);
    notifyListeners();
  }

  Future<void> updateUserIsPublic(bool isPublic) async {
    final uid = await getCurrentUserId();
    if (uid == null) {
      throw Exception('User not logged in');
    }
    await firebaseService.updateUserIsPublic(uid, isPublic);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    return await firebaseService.getUserByUsername(username);
  }

  Future<void> updateProfilePicture(File imageFile) async {
    try {
      final uid = await getCurrentUserId();
      if (uid == null) {
        throw Exception('User not logged in');
      }

      print('Starting profile picture update for user: $uid');

      // Get current user details
      final currentDetails = await firebaseService.getUserDetails(uid);
      if (currentDetails == null) {
        throw Exception('User not found for id: $uid');
      }

      print('Uploading image to Firebase Storage...');
      
      // Upload image to Firebase Storage
      final storageRef = _storage.ref();
      final profilePicRef = storageRef.child('profile_pictures/$uid.jpg');
      
      // Upload the file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': uid},
      );
      
      // Upload the file
      final uploadTask = await profilePicRef.putFile(imageFile, metadata);
      print('Upload completed. Bytes transferred: ${uploadTask.bytesTransferred}');
      
      // Get the download URL
      final downloadUrl = await profilePicRef.getDownloadURL();
      print('Download URL obtained: $downloadUrl');

      print('Updating user profile in Firestore...');
      
      // Update the profile picture URL in Firestore
      await firebaseService.editUser(
        uid: uid,
        profilePictureUrl: downloadUrl,
        firstName: currentDetails['firstName'],
        lastName: currentDetails['lastName'],
        email: currentDetails['email'],
        phoneNumber: currentDetails['phoneNumber'],
        userName: currentDetails['userName'],
        interests: List<String>.from(currentDetails['interests'] ?? []),
        travelPreferences: List<String>.from(currentDetails['travelPreferences'] ?? []),
      );

      print('Firestore update completed');

      // Update local state
      if (_userDetails != null) {
        _userDetails!['profilePictureUrl'] = downloadUrl;
      }
      
      notifyListeners();
      print('Profile picture update completed successfully');
    } catch (e, stackTrace) {
      print("Error updating profile picture: $e");
      print("Stack trace: $stackTrace");
      if (e is FirebaseException) {
        print("Firebase error code: ${e.code}");
        print("Firebase error message: ${e.message}");
      }
      rethrow;
    }
  }

  Future<void> updateProfileImage(String base64Image) async {
    try {
      await firebaseService.updateProfileImageBase64(base64Image);
      _profileImageBase64 = base64Image;
      notifyListeners();
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }

  /// Retrieve the base64 profile image string from Firestore (calls API)
  Future<String?> getProfileImageBase64({String? userId}) async {
    return await firebaseService.getProfileImageBase64(userId: userId);
  }
} 