import 'package:flutter/material.dart';
import 'package:project_abiyahe/api/firebase_user_api.dart';
import 'package:project_abiyahe/models/signup_values.dart';
import 'package:project_abiyahe/screens/user_profile_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseUserAPI _firebaseUserAPI = FirebaseUserAPI();
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _loadUserData(); // Refresh data when returning to this screen
  // }

  Future<void> _loadUserData() async {
    try {
      final userId = await _firebaseUserAPI.getCurrentUserId();
      if (userId != null) {
        final userDetails = await _firebaseUserAPI.getUserDetails(userId);
        if (userDetails != null) {
          setState(() {
            _user = User(
              userId: userId,
              firstName: userDetails['firstName'],
              lastName: userDetails['lastName'],
              userName: userDetails['userName'],
              email: userDetails['email'],
              phoneNumber: userDetails['phoneNumber'],
              profilePictureUrl: userDetails['profilePictureUrl'],
              interests: List<String>.from(userDetails['interests'] ?? []),
              travelPreferences: List<String>.from(userDetails['travelPreferences'] ?? []),
            );
            _isLoading = false;
          });
          return;
        }
      }
      setState(() {
        _error = 'No user found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading user data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

    return UserDetailsPage(user: _user);
  }
} 