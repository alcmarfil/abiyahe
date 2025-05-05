class User {
  String firstName;
  String lastName;
  String userName;
  String email;
  List<String>? interests;
  List<String>? travelPreferences;

  User({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    this.interests,
    this.travelPreferences,
  });
}
