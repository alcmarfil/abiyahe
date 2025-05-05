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
      validator:
          (val) =>
              val != null && val.contains('@')
                  ? null
                  : "Email should contain @",
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
          interests: formValues.interests,
          travelPreferences: formValues.travelPreferences,
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
