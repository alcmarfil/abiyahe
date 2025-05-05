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
  String? emailUSername, password;
  String? errorText;
  bool useUsername = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), automaticallyImplyLeading: false),
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
              useUsername ? usernameField() : emailField(),
              passwordField(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    useUsername = !useUsername;
                  });
                },
                child: Text(
                  useUsername
                      ? "Would you like to use your email instead?"
                      : "Would you like to use your username instead?",
                ),
              ),
              ElevatedButton(onPressed: submitAll, child: Text("Login")),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/signup');
                },
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (val) => emailUSername = val?.trim(),
      validator:
          (val) =>
              val != null && val.contains('@')
                  ? null
                  : "Email should contain @",
    );
  }

  Widget usernameField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Username",
      ),
      onSaved: (val) => emailUSername = val,
      validator:
          (val) =>
              val != null && val.isNotEmpty
                  ? null
                  : "Please enter your username",
    );
  }

  Widget passwordField() {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Password",
      ),
      obscureText: true,
      onSaved: (val) => password = val,
      validator:
          (val) =>
              val != null && val.isNotEmpty ? null : "Please enter a password",
    );
  }

  Future<void> submitAll() async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      setState(() {
        errorText = null;
      });

      try {
        String? error = await Provider.of<TravelProvider>(
          context,
          listen: false,
        ).login(
          email: emailUSername!,
          password: password!,
          useUsername: useUsername,
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
          errorText = "Error occured please try again!";
        });
      }
    }
  }
}
