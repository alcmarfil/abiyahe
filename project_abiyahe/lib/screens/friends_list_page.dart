import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/friends_provider.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  @override
  void initState() {
    super.initState();
    // Load friends when the page is first created
    Future.microtask(() => 
      context.read<FriendsProvider>().loadFriends()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FriendsProvider>().loadFriends(),
          ),
        ],
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, friendsProvider, child) {
          if (friendsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (friendsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(friendsProvider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => friendsProvider.loadFriends(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (friendsProvider.friends.isEmpty) {
            return const Center(
              child: Text('No friends yet'),
            );
          }

          return ListView.builder(
            itemCount: friendsProvider.friends.length,
            itemBuilder: (context, index) {
              final friend = friendsProvider.friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend.profilePictureUrl != null
                      ? NetworkImage(friend.profilePictureUrl!)
                      : const AssetImage('assets/default_pic.jpg') as ImageProvider,
                  child: friend.profilePictureUrl == null
                      ? null
                      : null,
                ),
                title: Text(friend.fullName),
                subtitle: Text('@${friend.userName}'),
                onTap: () {
                  // TODO: Navigate to friend's profile
                },
              );
            },
          );
        },
      ),
    );
  }
}
