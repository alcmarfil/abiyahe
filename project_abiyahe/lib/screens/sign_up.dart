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
  String? errorText;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

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
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 35,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: EdgeInsets.only(right: 8, bottom: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xff9cd8ff)
              : Color.fromARGB(255, 75, 116, 144).withOpacity(0.3),
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
                children: interests
                    .map((interest) => SizedBox(
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
                        ))
                    .toList(),
              ),
              SizedBox(height: 20),
              Text("Travel Preferences"),
              SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 10,
                children: travelPreferences
                    .map((style) => SizedBox(
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
                        ))
                    .toList(),
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
      controller: firstNameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "First Name",
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "Please Input a First name" : null,
    );
  }

  Widget lastName() {
    return TextFormField(
      controller: lastNameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Last Name",
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "Please input a last name" : null,
    );
  }

  Widget userName() {
    return TextFormField(
      controller: userNameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Username",
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "Please input a username" : null,
    );
  }

  Widget email() {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
        if (val == null || val.isEmpty || !emailRegex.hasMatch(val)) {
          return "Please enter a valid email format";
        }
        return null;
      },
    );
  }

  Widget password() {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
      obscureText: true,
      validator: (val) => passwordRegex.hasMatch(val ?? "")
          ? null
          : "Password must be 6+ chars, with uppercase, lowercase, number, and special character.",
    );
  }

  Future<void> submitAll() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => errorText = null);

      try {
        String? error = await Provider.of<TravelProvider>(
          context,
          listen: false,
        ).signup(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          userName: userNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          interests: selectedInterests,
          travelPreferences: selectedTravelPreferences,
        );

        if (error != null) {
          setState(() {
            errorText = error;
          });
        } else {
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
