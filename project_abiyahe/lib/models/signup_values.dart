class User {
   String? firstName;
   String? lastName;
   String? userName;
   String? email;
   String? password;
   List<String>? interests;
   List<String>? travelPreferences;
   String? profilePictureUrl;
   String? phoneNumber;
   String? userId;

   User({
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.password,
    this.interests,
    this.travelPreferences,
    this.profilePictureUrl,
    this.phoneNumber,
    this.userId,
   });

    
 }

//TODO: refactor
class SignUpForm {
  String? firstName;
  String? lastName;
  String? userName;
  String? email;
  String? password;
  List<String>? interests;
  List<String>? travelPreferences;
}
