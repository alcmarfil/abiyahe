import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? errorText;
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{6,}$',
  );

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


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
    final double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // Background circles
          Positioned(
            left: (parentWidth - 500) / 2,
            top: -410,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF25B1FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40797979).withOpacity(0.25),
                    offset: const Offset(-15, 15),
                    blurRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: (parentWidth - 302) / 2,
            top: -267,
            child: Container(
              width: 302,
              height: 302,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF25B1FF),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x40797979).withOpacity(0.25),
                    offset: const Offset(-15, 15),
                    blurRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Logo and Title at the top center
          const Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(height: 0),
                // Logo
                Center(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40797979),
                            offset: Offset(-15, 15),
                            blurRadius: 50,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.mode_of_travel_outlined,
                        color: Color(0xFF25B1FF),
                        size: 48,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Abiyahe",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF25B1FF),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Positioned.fill(
            top: 200,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SizedBox(height: 250),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(errorText!,
                              style: TextStyle(color: Colors.red)),
                        ),
                      Row(
                        children: [
                          Expanded(
                              child: labeledField(
                            label: "First Name",
                            icon: Icons.person_outlined,
                            hint: "First Name",
                            controller: _firstNameController,
                            validator: (val) => val == null || val.isEmpty
                                ? "Please Input a First name"
                                : null,
                          )),
                          SizedBox(width: 16),
                          Expanded(
                              child: labeledField(
                            label: "Last Name",
                            icon: Icons.person_outlined,
                            hint: "First Name",
                            controller: _lastNameController,
                            validator: (val) => val == null || val.isEmpty
                                ? "Please input a last name"
                                : null,
                          )),
                        ],
                      ),
                      SizedBox(height: 24),
                      labeledField(
                        label: "Username",
                        icon: Icons.person,
                        hint: "yourusername",
                        controller: _userNameController,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please input a username";
                          }
                          if (val.contains(' ')) {
                            return "Username must not contain spaces";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      labeledField(
                        label: "Email",
                        icon: Icons.mail_outline,
                        hint: "youremail@gmail.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          final emailRegex =
                              RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          if (val == null ||
                              val.isEmpty ||
                              !emailRegex.hasMatch(val)) {
                            return "Please enter a valid email format";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      labeledField(
                        label: "Password",
                        icon: Icons.lock_outline,
                        hint: "************",
                        controller: _passwordController,
                        obscureText: true,
                        validator: (val) => passwordRegex
                                .hasMatch(val ?? "")
                            ? null
                            : "The password must have at least 6 characters, \n one uppercase letter, one lowercase letter, one number, \n and one special character.",
                      ),
                      SizedBox(height: 32),
                      // Interests Section
                      Text(
                        "Interests",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),

                      SizedBox(height: 10),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 10,
                          children: interests
                              .map((interest) => SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                                80) /
                                            3,
                                    child: buildToggleButton(
                                      interest,
                                      selectedInterests.contains(interest),
                                      () => setState(() {
                                        if (selectedInterests
                                            .contains(interest)) {
                                          selectedInterests
                                              .remove(interest);
                                        } else {
                                          selectedInterests.add(interest);
                                        }
                                      }),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Travel Preferences Section

                      Text(
                        "Travel Preferences",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),

                      SizedBox(height: 10),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          runSpacing: 10,
                          children: travelPreferences
                              .map((style) => SizedBox(
                                    width:
                                        (MediaQuery.of(context).size.width -
                                                80) /
                                            3,
                                    child: buildToggleButton(
                                      style,
                                      selectedTravelPreferences
                                          .contains(style),
                                      () => setState(() {
                                        if (selectedTravelPreferences
                                            .contains(style)) {
                                          selectedTravelPreferences
                                              .remove(style);
                                        } else {
                                          selectedTravelPreferences
                                              .add(style);
                                        }
                                      }),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 40),
                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF25B1FF),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Centered Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xFF64B8F6),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget firstName() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "First Name",
      ),
      validator: (val) =>
          val == null || val.isEmpty ? "Please input a first name" : null,
    );
  }

  Widget lastName() {
    return TextFormField(
      controller: _lastNameController,
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
      controller: _userNameController,
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
      controller: _emailController,
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
      controller: _passwordController,
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
      print("Selected travel preference: $selectedTravelPreferences");
      print("Selected interests: $selectedInterests");

      try {
        String? error = await Provider.of<TravelProvider>(
          context,
          listen: false,
        ).signup(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          userName: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          interests: selectedInterests,
          travelPreferences: selectedTravelPreferences,
        );

        if (error != null) {
          setState(() {
            errorText = error;
          });
        } else {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/travel_plans');
        }
      } catch (e) {
        setState(() {
          errorText = "An error occurred. Please try again.";
        });
      }
    }
  }

  Widget labeledField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[700]),
            hintText: hint,
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF25B1FF), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }
}



