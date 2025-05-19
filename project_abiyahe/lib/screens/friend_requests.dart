import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final FirebaseUserAPI _firebaseUserAPI = FirebaseUserAPI();
  List<String> receivedRequests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getRequests();
  }

  Future<void> getRequests() async {
    try {
      final userId = await _firebaseUserAPI.getCurrentUserId();
      if (userId == null) return;
      print("User ID: $userId");
      final currentUser = await _firebaseUserAPI.getUserDetails(userId);
      if (currentUser == null) return;
      print(currentUser);

      final requests = List<String>.from(currentUser['receivedRequests'] ?? []);
      print("Received requests: $requests");

      setState(() {
        receivedRequests = requests;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("Error loading friend requests: $e");
    }
  }

  Future<void> acceptRequest(String username) async {
    final uid = await _firebaseUserAPI.getCurrentUserId();
    if (uid != null) {
      setState(() {
        receivedRequests.remove(username);
      });

      await _firebaseUserAPI.acceptFriendRequest(uid, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Accepted $username")),
      );
    }
  }

  Future<void> declineRequests(String username) async {
    final uid = await _firebaseUserAPI.getCurrentUserId();
    if (uid != null) {
      setState(() {
        receivedRequests.remove(username);
      });

      await _firebaseUserAPI.declineFriendRequest(uid, username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Declined $username")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : receivedRequests.isEmpty
              ? const Center(child: Text("No friend requests."))
              : ListView.builder(
                  itemCount: receivedRequests.length,
                  itemBuilder: (context, index) {
                    final requester = receivedRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(requester),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.check, color: Colors.green),
                              onPressed: () => acceptRequest(requester),
                              tooltip: "Accept",
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => declineRequests(requester),
                              tooltip: "Decline",
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
