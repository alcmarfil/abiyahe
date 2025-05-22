import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:project_abiyahe/services/notification_service.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _notificationService = LocalNotificationService();

  User? get currentUser => _auth.currentUser;

  Future<String?> getCurrentUserId() async {
    try {
      final user = _auth.currentUser;
      return user?.uid;
    } catch (e) {
      print("Error getting current user ID: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      final doc = await db.collection('Users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        return {
          'firstName': data?['firstName'] ?? '',
          'lastName': data?['lastName'] ?? '',
          'email': data?['email'] ?? '',
          'phoneNumber': data?['phoneNumber'] ?? '',
          'userName': data?['userName'] ?? '',
          'profilePictureUrl': data?['profilePictureUrl'] ?? '',
          'interests': data?['interests'] ?? [],
          'travelPreferences': data?['travelPreferences'] ?? [],
          'friends': data?['friends'] ?? [],
          'isPublic': data?['isPublic'] ?? true,
          'receivedRequests': data?['receivedRequests'] ?? [],
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> editUser({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String userName,
    required String profilePictureUrl,
    required List<String> interests,
    required List<String> travelPreferences,
  }) async {
    try {
      //update the attributes
      await db.collection('Users').doc(uid).update({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'userName': userName,
        'profilePictureUrl': profilePictureUrl,
        'interests': interests,
        'travelPreferences': travelPreferences,
      });

      return 'Successfully edited profile!';
    } on FirebaseException catch (e) {
      return 'Error: ${e.message}';
    }
  }

  Future<void> signOut() async {
    try {
      // Clear FCM token before signing out
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await db.collection('Users').doc(userId).update({
          'fcmToken': FieldValue.delete(),
          'lastTokenUpdate': FieldValue.delete(),
        });
      }

      // Sign out from Firebase Auth
      await _auth.signOut();
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Expose auth state changes as a stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().map((user) {
      print('Auth state changed: ${user?.uid ?? 'null'}');
      return user;
    });
  }

  Future<bool> canShareWithFriends(
      String currentUserId, List<String> usernames) async {
    final userDoc = await db.collection('Users').doc(currentUserId).get();
    final friends = List<String>.from(userDoc.data()?['friends'] ?? []);
    // Check if all usernames are in friends
    return usernames.every((u) => friends.contains(u));
  }

  Future<String?> signUp({
    required String firstName,
    required String lastName,
    required String userName,
    required String email,
    required String password,
    List<String>? interests,
    List<String>? travelPreferences,
  }) async {
    try {
      final checkUser = await db
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
      final user = userCredential.user;

      if (user != null) {
        await db.collection("Users").doc(user.uid).set({
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "userName": userName,
          "userId": user.uid,
          "interests": interests,
          "travelPreferences": travelPreferences,
        });
      }
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
        final userSnapshot = await db
            .collection("Users")
            .where("userName", isEqualTo: email)
            .get();
        if (userSnapshot.docs.isNotEmpty) {
          loginChoice = userSnapshot.docs.first["email"];
        } else {
          throw Exception('User not found');
        }
      }

      await _auth.signInWithEmailAndPassword(
        email: loginChoice,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email/username');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later');
        case 'network-request-failed':
          throw Exception('Network error. Please check your connection');
        default:
          throw Exception('An error occurred: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await db.collection("Users").doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<void> sendFriendRequest(String uid, String friendUsername) async {
    final userDoc = db.collection('Users');
    final friendDoc = await db
        .collection('Users')
        .where('userName', isEqualTo: friendUsername)
        .get();
    final friendId = friendDoc.docs.first.id;
    final currentUserDoc = await userDoc.doc(uid).get();
    final currentUserName = currentUserDoc.data()?['userName'] ?? '';

    await userDoc.doc(uid).update({
      'sentRequests': FieldValue.arrayUnion([friendUsername]),
    });
    await userDoc.doc(friendId).update({
      'receivedRequests': FieldValue.arrayUnion([currentUserName]),
    });
  }

  Future<void> acceptFriendRequest(String uid, String friendUsername) async {
    final userDoc = db.collection('Users');
    final friendDoc = await db
        .collection('Users')
        .where('userName', isEqualTo: friendUsername)
        .get();
    final friendId = friendDoc.docs.first.id;
    final currentUserDoc = await userDoc.doc(uid).get();
    final currentUserName = currentUserDoc.data()?['userName'] ?? '';

    final currentUserSentRequests = List<String>.from(currentUserDoc.data()?['sentRequests'] ?? []);
    final hasCrossRequest = currentUserSentRequests.contains(friendUsername);

    await userDoc.doc(uid).update({
      'friends': FieldValue.arrayUnion([friendUsername]),
      'receivedRequests': FieldValue.arrayRemove([friendUsername]),
      if (hasCrossRequest) 'sentRequests': FieldValue.arrayRemove([friendUsername]),
    });
    await userDoc.doc(friendId).update({
      'friends': FieldValue.arrayUnion([currentUserName]),
      'sentRequests': FieldValue.arrayRemove([currentUserName]),
      'receivedRequests': FieldValue.arrayRemove([currentUserName]),
    });
  }

  Future<void> declineFriendRequest(String uid, String friendUsername) async {
    final userDoc = db.collection('Users');
    final friendDoc = await db
        .collection('Users')
        .where('userName', isEqualTo: friendUsername)
        .get();
    final friendId = friendDoc.docs.first.id;
    final currentUserDoc = await userDoc.doc(uid).get();
    final currentUserName = currentUserDoc.data()?['userName'] ?? '';

    await userDoc.doc(uid).update({
      'sentRequests': FieldValue.arrayRemove([friendUsername]),
    });
    await userDoc.doc(friendId).update({
      'receivedRequests': FieldValue.arrayRemove([
        currentUserName,
      ]),
    });
  }

  Future<void> updateUserIsPublic(String uid, bool isPublic) async {
    await db.collection('Users').doc(uid).update({'isPublic': isPublic});
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await db
          .collection('Users')
          .where('userName', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  // FCM Token methods
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  Future<void> storeFCMToken(String token) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await db.collection('Users').doc(userId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('FCM Token stored successfully for user: $userId');
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Retrieve the base64 profile image string from Firestore
  Future<String?> getProfileImageBase64({String? userId}) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) {
        print('No user ID provided when trying to get profile image');
        return null;
      }
      final doc = await db.collection('Users').doc(uid).get();
      final profilePic = doc.data()?['profilePictureUrl'];
      if (profilePic == null || profilePic.isEmpty) {
        print('No profile picture found for user');
        return null;
      }
      return profilePic;
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  /// Store a profile image as a base64 string in Firestore
  Future<void> updateProfileImageBase64(String base64Image) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        print('No user logged in when trying to update profile image');
        return;
      }
      await db.collection('Users').doc(uid).update({
        'profilePictureUrl': base64Image,
      });
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow;
    }
  }
}
