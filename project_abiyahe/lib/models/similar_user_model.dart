class SimilarUser {
  final String userName;
  final List<String> sharedInterests;
  final List<String> sharedPreferences;
  final String? profilePictureUrl;

  SimilarUser({
    required this.userName,
    required this.sharedInterests,
    required this.sharedPreferences,
    this.profilePictureUrl,
  });

  factory SimilarUser.fromMap(Map<String, dynamic> map) {
    return SimilarUser(
      userName: map['userName'] ?? '',
      sharedInterests: List<String>.from(map['sharedInterests'] ?? []),
      sharedPreferences: List<String>.from(map['sharedPreferences'] ?? []),
      profilePictureUrl: map['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'sharedInterests': sharedInterests,
      'sharedPreferences': sharedPreferences,
      'profilePictureUrl': profilePictureUrl,
    };
  }
} 