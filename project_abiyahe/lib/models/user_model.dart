class User {
  String firstName;
  String lastName;
  String userName;
  String email;
  List<String>? interests;
  List<String>? travelPreferences;
  String? userId;
  String? profilePictureUrl;
  String? phoneNumber;
  List<String>? friends;
  bool? isPublic;
  List<String>? sentRequests;
  List<String>? receivedRequests;


  User({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    this.interests,
    this.travelPreferences,
    this.userId,
    this.profilePictureUrl,
    this.phoneNumber,
    this.friends,
    this.isPublic,
    this.sentRequests,
    this.receivedRequests,
  });

}


  