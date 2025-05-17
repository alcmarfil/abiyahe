import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
import 'package:project_abiyahe/common/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_abiyahe/common/navbar.dart';

class SimilarUser {
  final String userName;
  final List<String> sharedInterests;
  final List<String> sharedPreferences;
  final String? profilePicUrl;

  SimilarUser({
    required this.userName,
    required this.sharedInterests,
    required this.sharedPreferences,
    this.profilePicUrl,
  });
}

class FindSimilarPeoplePage extends StatefulWidget {
  const FindSimilarPeoplePage({super.key});

  @override
  State<FindSimilarPeoplePage> createState() => _FindSimilarPeoplePageState();
}

class _FindSimilarPeoplePageState extends State<FindSimilarPeoplePage> {
  final FirebaseUserAPI _firebaseUserAPI = FirebaseUserAPI();
  List<SimilarUser> similarPeople = [];
  String? _error;
  // bool _isLoading = true;

  var selectedIndex = 2;
  @override
  void initState() {
    super.initState();
    getSimilarPeople();
  }

  Future<void> getSimilarPeople() async {
    try {
      final userId = await _firebaseUserAPI.getCurrentUserId();
      if (userId == null) return;

      final currentUser = await _firebaseUserAPI.getUserDetails(userId);
      if (currentUser == null) return;

      final currentInterests = List<String>.from(
        currentUser['interests'] ?? [],
      );
      final currentPrefs = List<String>.from(
        currentUser['travelPreferences'] ?? [],
      );
      final currentFriends = List<String>.from(
        currentUser['friends'] ?? [],
      );
      print(currentFriends);
      final users = await FirebaseFirestore.instance.collection('Users').get();

      List<SimilarUser> matches = [];

      for (var doc in users.docs) {
        if (doc.id == userId) continue;

        final data = doc.data() as Map<String, dynamic>;
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

        if (sameInterests.isNotEmpty && samePreferences.isNotEmpty) {
          matches.add(
            SimilarUser(
              userName: userName.isNotEmpty ? userName : 'Username doko?',
              sharedInterests: sameInterests,
              sharedPreferences: samePreferences,
              profilePicUrl: data['profilePicUrl'],
            ),
          );
        }
      }

      setState(() {
        similarPeople = matches;
      });
    } catch (e) {
      setState(() {
        _error = 'Error message tbd: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: const DrawerWidget(),
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          "Find Similar People",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: IconButton(
              icon: const Icon(Icons.mail_outline, color: Colors.white, size: 30),
              tooltip: 'Friend Requests',
              onPressed: () {
                // TODO: Navigate to friend requests page
              },
            ),
          ),
        ],
      ),
      body: _error != null
          ? Center(child: Text(_error!))
          : similarPeople.isEmpty
              ? const Center(child: Text("No similar people found."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: similarPeople.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 0.55,
                    ),
                    itemBuilder: (context, index) {
                      final user = similarPeople[index];
                      return _buildUserCard(user);
                    },
                  ),
                ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) => (index),
      ),
    );
  }

  Widget _buildUserCard(SimilarUser user) {
    const defaultPic = 'assets/default_pic.jpg';

    return Container(
      decoration: BoxDecoration(
        color: Color(0xff25b1ff),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(
              (user.profilePicUrl != null && user.profilePicUrl!.isNotEmpty)
                  ? user.profilePicUrl!
                  : defaultPic,
            ),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            user.userName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          if (user.sharedInterests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 8, right: 8),
              child: Text(
                'Similar Interests: ${user.sharedInterests.join(', ')}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          if (user.sharedPreferences.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0, left: 8, right: 8),
              child: Text(
                'Similar Travel Styles: ${user.sharedPreferences.join(', ')}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff25b1ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: const Size.fromHeight(40),
              ),
              icon: const Icon(Icons.person_add, color: Color(0xff25b1ff)),
              label: const Text("Add friend"),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
