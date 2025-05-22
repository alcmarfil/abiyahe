import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailUsernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorText;
  bool useUsername = false;

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double parentWidth = constraints.maxWidth;
          return Form(
            key: formKey,
            child: Stack(
              children: [
                // Ellipse 3 (largest, at the back)
                Positioned(
                  left: (parentWidth - 485) / 2,
                  top: -285,
                  child: Container(
                    width: 485,
                    height: 485,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF25B1FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x29535353).withOpacity(0.18),
                          offset: const Offset(2, 2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                // Ellipse 2
                Positioned(
                  left: (parentWidth - 383) / 2,
                  top: -267,
                  child: Container(
                    width: 383,
                    height: 383,
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
                // Ellipse 1 (smallest, at the front)
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
                // Main content
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Stack for background and logo
                        Stack(
                        alignment: Alignment.center,
                        children: [
                          // Logo
                          Column(
                            children: [
                              const SizedBox(height: 150),
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0x40797979).withOpacity(0.25),
                                      offset: const Offset(-15, 15),
                                      blurRadius: 50,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.mode_of_travel_outlined,
                                  color: const Color(0xFF25B1FF),
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      useUsername ? usernameField() : emailField(),
                      const Divider(),
                      passwordField(),
                      const Divider(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            useUsername = !useUsername;
                            emailUsernameController.clear();
                            passwordController.clear();
                          });
                        },
                        child: Text(
                          useUsername
                              ? "Would you like to use your email instead?"
                              : "Would you like to use your username instead?",
                        ),
                      ),
                      // Login button
                      SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25B1FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sign Up button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/signup');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: Colors.black, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      controller: emailUsernameController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: "Email",
        prefixIcon: Icon(Icons.mail_outline),
        hintText: "youremail@gmail.com",
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Please enter your email";
        }
        final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
        if (!emailRegex.hasMatch(val)) {
          return "Enter a valid email address";
        }
        return null;
      },
    );
  }

  Widget usernameField() {
    return TextFormField(
      controller: emailUsernameController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: "Username",
        prefixIcon: Icon(Icons.person_outline),
        hintText: "yourusername",
      ),
      validator: (val) =>
          val != null && val.isNotEmpty ? null : "Please enter your username",
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: passwordController,
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: "Password",
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: true,
      validator: (val) =>
          val != null && val.isNotEmpty ? null : "Please enter a password",
    );
  }

  Future<void> submitAll() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        errorText = null;
      });

      try {
        await Provider.of<TravelProvider>(
          context,
          listen: false,
        ).login(
          email: emailUsernameController.text.trim(),
          password: passwordController.text,
          useUsername: useUsername,
        );
        // Navigate to travel plans page after successful login
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/travel_plans');
        }
      } catch (e) {
        setState(() {
          errorText = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }
}
