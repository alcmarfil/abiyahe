import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String?> getCurrentUserId() async {
    try {
      // get the first user document from the Users collection
      final querySnapshot = await db.collection('Users').limit(1).get();
      
      if (querySnapshot.docs.isNotEmpty) {
        // return the document ID as the user ID
        return querySnapshot.docs.first.id;
      }
      return null;
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


}
