class Friend {
  final String userId;
  final String firstName;
  final String lastName;
  final String userName;
  final String? profilePictureUrl;

  Friend({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.userName,
    this.profilePictureUrl,
  });

  String get fullName => '$firstName $lastName';

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      userName: map['userName'] ?? '',
      profilePictureUrl: map['profilePictureUrl'],
    );
  }
} 