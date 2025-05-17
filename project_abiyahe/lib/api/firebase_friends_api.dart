import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_abiyahe/models/friend_model.dart';

class FirebaseFriendsAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Friend>> getFriendsList(String userId) async {
    try {
      // get the user document
      final userDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        return [];
      }

      final userData = userDoc.data()!;
      final List<dynamic> friendsList = userData['friends'] ?? [];
      // print('friendsList: $friendsList');
      List<Friend> friends = [];
      
      // For each username in the user's friends list
      for (var username in friendsList) {
        // Query users collection to find the user with this username
        final querySnapshot = await _firestore
            .collection('Users')
            .where('userName', isEqualTo: username)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          final friendData = querySnapshot.docs.first.data();
          friends.add(Friend.fromMap({
            'userId': friendData['userId'] ?? '',
            'firstName': friendData['firstName'] ?? '',
            'lastName': friendData['lastName'] ?? '',
            'userName': friendData['userName'] ?? '',
            'profilePictureUrl': friendData['profilePictureUrl'],
          }));
        }
      }
      // print('friends: $friends');
      return friends;
    } catch (e) {
      print('Error getting friends list: $e');
      return [];
    }
  }
} 