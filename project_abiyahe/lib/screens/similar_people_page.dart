import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/common/navbar.dart';
import 'package:project_abiyahe/models/similar_user_model.dart';
import 'package:project_abiyahe/providers/friends_provider.dart';
import 'package:project_abiyahe/screens/friend_requests.dart';
import 'package:project_abiyahe/screens/user_profile_page.dart';
import 'dart:convert';

class FindSimilarPeoplePage extends StatefulWidget {
  const FindSimilarPeoplePage({super.key});

  @override
  State<FindSimilarPeoplePage> createState() => _FindSimilarPeoplePageState();
}

class _FindSimilarPeoplePageState extends State<FindSimilarPeoplePage> {
  var selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    // widgets binding instance is used to load the similar users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendsProvider>(context, listen: false).loadSimilarUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          "Find Similar People",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: IconButton(
              icon: const Icon(Icons.mail_outline, color: Colors.white, size: 30),
              tooltip: 'Friend Requests',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendRequestsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.similarUsers.isEmpty) {
            return const Center(child: Text("No similar people found."));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: provider.similarUsers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.7,
              ),
              itemBuilder: (context, index) {
                final user = provider.similarUsers[index];
                return SizedBox(
                  height: 240,
                  child: _buildUserCard(context, user, provider),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) => (index),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, SimilarUser user, FriendsProvider provider) {
    final hasSentRequest = provider.hasSentRequestTo(user.userName); // check if the current user has sent a request to user

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(
              targetUsername: user.userName,
              isReadOnly: true,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff25b1ff),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              backgroundImage: (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
                  ? (user.profilePictureUrl!.startsWith('data:image') || user.profilePictureUrl!.startsWith('data:image/jpeg'))
                      ? MemoryImage(base64Decode(user.profilePictureUrl!.split(',')[1])) as ImageProvider
                      : NetworkImage(user.profilePictureUrl!) as ImageProvider
                  : const AssetImage('assets/default_pic.jpg') as ImageProvider,
            ),
            const SizedBox(height: 12),
            Text(
              '@${user.userName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            // if (user.sharedInterests.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 2.0, left: 8, right: 8),
            //     child: Text(
            //       'Similar Interests: ${user.sharedInterests.join(', ')}',
            //       textAlign: TextAlign.center,
            //       style: const TextStyle(
            //         fontSize: 10,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // if (user.sharedPreferences.isNotEmpty)
            //   Padding(
            //     padding: const EdgeInsets.only(top: 2.0, left: 8, right: 8),
            //     child: Text(
            //       'Similar Travel Styles: ${user.sharedPreferences.join(', ')}',
            //       textAlign: TextAlign.center,
            //       style: const TextStyle(
            //         fontSize: 10,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSentRequest ? Colors.grey : Colors.white,
                  foregroundColor: hasSentRequest ? Colors.white : const Color(0xff25b1ff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size.fromHeight(40),
                ),
                icon: Icon(
                  hasSentRequest ? Icons.check : Icons.person_add,
                  color: hasSentRequest ? Colors.white : const Color(0xff25b1ff),
                ),
                label: Text(hasSentRequest ? "Request Sent" : "Add friend"),
                onPressed: hasSentRequest
                    ? null
                    : () async {
                        try {
                          await provider.sendFriendRequest(user.userName);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Friend request sent to ${user.userName}'),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

