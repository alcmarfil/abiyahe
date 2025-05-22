import 'package:flutter/foundation.dart';
import 'package:project_abiyahe/api/firebase_friends_api.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
import 'package:project_abiyahe/models/friend_model.dart';
import 'package:project_abiyahe/models/similar_user_model.dart';

class FriendsProvider with ChangeNotifier {
  final FirebaseFriendsAPI _friendsAPI = FirebaseFriendsAPI();
  final FirebaseUserAPI _userAPI = FirebaseUserAPI();
  List<Friend> _friends = [];
  List<String> _receivedRequests = [];
  List<String> _sentRequests = [];
  List<SimilarUser> _similarUsers = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  List<String> get receivedRequests => _receivedRequests;
  List<String> get sentRequests => _sentRequests;
  List<SimilarUser> get similarUsers => _similarUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFriendRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        final userDetails = await _userAPI.getUserDetails(userId);
        if (userDetails != null) {
          _receivedRequests = List<String>.from(userDetails['receivedRequests'] ?? []);
        }
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error loading friend requests: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        await Future.wait([
          _loadFriendsList(userId),
          _loadRequests(userId),
        ]);
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error loading friends: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFriendsList(String userId) async {
    _friends = await _friendsAPI.getFriendsList(userId);
  }

  Future<void> _loadRequests(String userId) async {
    final userDetails = await _userAPI.getUserDetails(userId);
    if (userDetails != null) {
      _receivedRequests = List<String>.from(userDetails['receivedRequests'] ?? []);
      _sentRequests = List<String>.from(userDetails['sentRequests'] ?? []);
    }
  }

  Future<void> loadSimilarUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = await _userAPI.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      _similarUsers = await _friendsAPI.getSimilarUsers(currentUserId);
      await loadSentRequests();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        await _userAPI.acceptFriendRequest(userId, username);
        _receivedRequests.remove(username);
        await loadFriends();
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error accepting friend request: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> declineFriendRequest(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        await _userAPI.declineFriendRequest(userId, username);
        _receivedRequests.remove(username);
        await loadFriends();
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error declining friend request: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest(String targetUsername) async {
    try {
      final currentUserId = await _userAPI.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      await _friendsAPI.sendFriendRequest(currentUserId, targetUsername);
      _sentRequests.add(targetUsername);
      notifyListeners();
    } catch (e) {
      print('Error sending friend request: $e');
      rethrow;
    }
  }

  Future<void> loadSentRequests() async {
    try {
      final currentUserId = await _userAPI.getCurrentUserId();
      if (currentUserId != null) {
        _sentRequests = await _friendsAPI.getSentRequests(currentUserId);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading sent requests: $e');
    }
  }

  bool hasSentRequestTo(String username) {
    return _sentRequests.contains(username);
  }

  Future<List<String>> getReceivedRequestUsernames() async {
    List<String> usernames = [];
    for (String userId in _receivedRequests) {
      if (userId.isEmpty) continue;
      final userDetails = await _userAPI.getUserDetails(userId);
      if (userDetails != null && userDetails['userName'] != null) {
        usernames.add(userDetails['userName']);
      }
    }
    return usernames;
  }
}
