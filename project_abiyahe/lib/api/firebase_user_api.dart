import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
          'pendingRequests': data?['pendingRequests'] ?? [],
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
    await _auth.signOut();
  }

  // Expose auth state changes as a stream
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
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
          return 'User not found';
        }
      }

      await _auth.signInWithEmailAndPassword(
        email: loginChoice,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        return 'Incorrect email';
      } else {
        return e.message;
      }
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
      'pendingRequests': FieldValue.arrayUnion([friendUsername]),
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

    await userDoc.doc(uid).update({
      'friends': FieldValue.arrayUnion([friendUsername]),
      'receivedRequests': FieldValue.arrayRemove([friendUsername]),
    });
    await userDoc.doc(friendId).update({
      'friends': FieldValue.arrayUnion([currentUserName]),
      'pendingRequests': FieldValue.arrayRemove([currentUserName]),
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
      'pendingRequests': FieldValue.arrayRemove([friendUsername]),
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
}
