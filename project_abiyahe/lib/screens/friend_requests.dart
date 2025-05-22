import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/friends_provider.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  @override
  void initState() {
    super.initState();
    getRequests();
  }

  Future<void> getRequests() async {
    try {
      final provider = Provider.of<FriendsProvider>(context, listen: false);
      await provider.loadFriendRequests(); 
    } catch (e) {
      print("Error loading friend requests: $e");
    }
  }

  Future<void> acceptRequest(String username) async {
    try {
      final provider = Provider.of<FriendsProvider>(context, listen: false);
      await provider.acceptFriendRequest(username);
      await getRequests(); // Refresh just the requests
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Accepted $username")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error accepting request: $e")),
        );
      }
    }
  }

  Future<void> declineRequests(String username) async {
    try {
      final provider = Provider.of<FriendsProvider>(context, listen: false);
      await provider.declineFriendRequest(username);
      await getRequests(); // Refresh just the requests
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Declined $username")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error declining request: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Requests"),
        backgroundColor: const Color(0xff25b1ff),
        foregroundColor: Colors.white,
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          if (provider.receivedRequests.isEmpty) {
            return const Center(child: Text("No friend requests."));
          }

          return ListView.builder(
            itemCount: provider.receivedRequests.length,
            itemBuilder: (context, index) {
              final username = provider.receivedRequests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('@$username'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => acceptRequest(username),
                        tooltip: "Accept",
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => declineRequests(username),
                        tooltip: "Decline",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
