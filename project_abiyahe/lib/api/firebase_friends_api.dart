import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_abiyahe/models/friend_model.dart';
import 'package:project_abiyahe/models/similar_user_model.dart';

class FirebaseFriendsAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Friend>> getFriendsList(String userId) async {
    try {
      // get the user document
      final userDoc = await _firestore.collection('Users').doc(userId).get();

      if (!userDoc.exists) {
        return [];
      }

      final userData = userDoc.data()!;
      final List<dynamic> friendsList = userData['friends'] ?? [];
      // print('friendsList: $friendsList');
      List<Friend> friends = [];

      // For each username in the user's friends list
      for (var username in friendsList) {
        // query users collection to find the user with this username
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

  Future<List<SimilarUser>> getSimilarUsers(String userId) async {
    try {
      final currentUserDoc =
          await _firestore.collection('Users').doc(userId).get();
      if (!currentUserDoc.exists) return [];

      final currentUserData = currentUserDoc.data()!;
      final currentInterests =
          List<String>.from(currentUserData['interests'] ?? []);
      final currentPrefs =
          List<String>.from(currentUserData['travelPreferences'] ?? []);
      final currentFriends =
          List<String>.from(currentUserData['friends'] ?? []);

      final users = await _firestore.collection('Users').get();
      List<SimilarUser> matches = [];

      for (var doc in users.docs) {
        if (doc.id == userId) continue;

        final data = doc.data();
        final interests = List<String>.from(data['interests'] ?? []);
        final preferences = List<String>.from(data['travelPreferences'] ?? []);
        final isPublic = data['isPublic'] ?? true;
        final userName = data['userName'] ?? '';

        // Only show if not friends and is public
        if (currentFriends.contains(userName)) {
          continue;
        }
        if (!isPublic) {
          continue;
        }

        final sameInterests =
            currentInterests.where(interests.contains).toList();
        final samePreferences =
            currentPrefs.where(preferences.contains).toList();

        if (sameInterests.isNotEmpty || samePreferences.isNotEmpty) {
          // print('Loading user: $userName');
          // print('Raw data from Firestore: $data');
          // print('Profile picture URL from Firestore: ${data['profilePictureUrl']}');
          final similarUser = SimilarUser(
            userName: userName.isNotEmpty ? userName : 'Username doko?',
            sharedInterests: sameInterests,
            sharedPreferences: samePreferences,
            profilePictureUrl: data['profilePictureUrl'] ?? '',
          );
          // print('Created SimilarUser with profile picture URL: ${similarUser.profilePictureUrl}');
          matches.add(similarUser);
        }
      }

      return matches;
    } catch (e) {
      print('Error getting similar users: $e');
      return [];
    }
  }

  Future<List<String>> getSentRequests(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('sentRequests')) {
          return List<String>.from(data['sentRequests'] ?? []);
        }
      }
      return [];
    } catch (e) {
      print('Error getting sent requests: $e');
      return [];
    }
  }

  Future<void> sendFriendRequest(String senderId, String targetUsername) async {
    try {
      final usersQuery = await _firestore
          .collection('Users')
          .where('userName', isEqualTo: targetUsername)
          .get();

      if (usersQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final targetUserId = usersQuery.docs.first.id;

      // get the sender's username
      final senderDoc =
          await _firestore.collection('Users').doc(senderId).get();
      final senderUserName = senderDoc.data()?['userName'];

      // add to sent requests in sender's document
      await _firestore.collection('Users').doc(senderId).update({
        'sentRequests': FieldValue.arrayUnion([targetUsername])
      });

      // add to received requests in target's document (store sender's username)
      await _firestore.collection('Users').doc(targetUserId).update({
        'receivedRequests': FieldValue.arrayUnion([senderUserName])
      });
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

} 