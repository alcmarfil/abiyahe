import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider.dart';
import '/models/signup_values.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  SignUpForm formValues = SignUpForm();
  String? errorText;

  List<String> interests = [
    "Adventure",
    "Beach",
    "Culture",
    "Food",
    "Nature",
    "Relaxation",
  ];
  List<String> travelPreferences = [
    "Budget",
    "Luxury",
    "Solo",
    "Family",
    "Group",
    "Couple",
  ];


  List<String> selectedInterests = [];
  List<String> selectedTravelPreferences = [];


  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{6,}$',
  );

  Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Fixed width
        height: 35,  // Fixed height
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: EdgeInsets.only(right: 8, bottom: 5),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff9cd8ff) : Color.fromARGB(255, 75, 116, 144).withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(errorText!, style: TextStyle(color: Colors.red)),
                ),
              firstName(),
              lastName(),
              userName(),
              email(),
              password(),
              const SizedBox(height: 20),
              Text("Interests"),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: interests.map((interest) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: buildToggleButton(
                          interest,
                          selectedInterests.contains(interest),
                          () => setState(() {
                            if (selectedInterests.contains(interest)) {
                              selectedInterests.remove(interest);
                            } else {
                              selectedInterests.add(interest);
                            }
                          }),
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: 20),
                    Text("Travel Preferences"),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: travelPreferences.map((style) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: buildToggleButton(
                          style,
                          selectedTravelPreferences.contains(style),
                          () => setState(() {
                            if (selectedTravelPreferences.contains(style)) {
                              selectedTravelPreferences.remove(style);
                            } else {
                              selectedTravelPreferences.add(style);
                            }
                          }),
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitAll,
                child: Text("Create Account"),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget firstName() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "First Name",
      ),
      onSaved: (val) => formValues.firstName = val?.trim(),
      validator:
          (val) =>
              val == null || val.isEmpty ? "Please Input a First name" : null,
    );
  }

  Widget lastName() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Last Name",
      ),
      onSaved: (val) => formValues.lastName = val?.trim(),
      validator:
          (val) =>
              val == null || val.isEmpty ? "PLease input a last name" : null,
    );
  }

  Widget userName() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Username",
      ),
      onSaved: (val) => formValues.userName = val?.trim(),
      validator:
          (val) =>
              val == null || val.isEmpty ? "Please input a username" : null,
    );
  }

  Widget email() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (val) => formValues.email = val?.trim(),
      validator: (val) {
         final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"); //to check if it is a valid email
        if (val == null || val.isEmpty || !emailRegex.hasMatch(val)) {
          return "Please enter a valid email format";
        }
        return null;
      },
    );
  }

  Widget password() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
      obscureText: true,
      onSaved: (val) => formValues.password = val,
      validator:
          (val) =>
              passwordRegex.hasMatch(val ?? "")
                  ? null
                  : "The password must have at least 6 characters, one uppercase letter, one lowercase letter, one number, and one special character.",
    );
  }

  Future<void> submitAll() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();
      setState(() => errorText = null);
      print("Selected travel preference: $selectedTravelPreferences");
      print("Selected interests: $selectedInterests");


      try {
        String? error = await Provider.of<TravelProvider>(
          context,
          listen: false,
        ).signup(
          firstName: formValues.firstName!,
          lastName: formValues.lastName!,
          userName: formValues.userName!,
          email: formValues.email!,
          password: formValues.password!,
          interests: selectedInterests,
          travelPreferences: selectedTravelPreferences,
        );

        if (error != null) {
          setState(() {
            errorText = error;
          });
        } else {
          // Success
          Navigator.of(context).pushReplacementNamed('/travel_plans');
        }
      } catch (e) {
        setState(() {
          errorText = "An error occurred. Please try again.";
        });
      }
    }
  }
}
