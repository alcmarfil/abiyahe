import 'package:flutter/foundation.dart';
import 'package:project_abiyahe/api/firebase_friends_api.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
import 'package:project_abiyahe/models/friend_model.dart';

class FriendsProvider with ChangeNotifier {
  final FirebaseFriendsAPI _friendsAPI = FirebaseFriendsAPI();
  final FirebaseUserAPI _userAPI = FirebaseUserAPI();
  List<Friend> _friends = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        _friends = await _friendsAPI.getFriendsList(userId);
        print('friends: $_friends');
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error loading friends: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptFriendRequest(String username) async {
    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        await _userAPI.acceptFriendRequest(userId, username);
        await loadFriends();
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error accepting friend request: $e';
    }
    notifyListeners();
  }

  Future<void> declineFriendRequest(String username) async {
    try {
      final userId = await _userAPI.getCurrentUserId();
      if (userId != null) {
        await _userAPI.declineFriendRequest(userId, username);
        await loadFriends();
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = 'Error declining friend request: $e';
    }
    notifyListeners();
  }
}
