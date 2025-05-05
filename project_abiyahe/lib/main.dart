import 'package:project_abiyahe/firebase_options.dart';
import 'package:project_abiyahe/models/signup_values.dart';
import 'package:project_abiyahe/screens/similar_people_page.dart';
import 'package:project_abiyahe/screens/travel_plans_page.dart';
import 'package:project_abiyahe/providers/firebase_provider.dart';
import 'package:project_abiyahe/screens/user_profile_page.dart';
import '/screens/login.dart';
import '/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project_abiyahe/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/screens/profile_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TravelProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: AppBarTheme(
          color: Colors.indigo,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      initialRoute: '/signup',
      routes: {
        '/signup': (context) => SignUp(),
        '/login': (context) => Login(),
        '/travel_plans': (context) => TravelPlansPage(),
        '/similar_people': (context) => FindSimilarPeoplePage(),
        '/profile': (context) => UserDetailsPage(user: User(),),
      },
    );
  }
}

// class FormPage extends StatefulWidget {
//   const FormPage({super.key});

//   @override
//   State<FormPage> createState() => _FormPageState();
// }

// class _FormPageState extends State<FormPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Form and Form Input Widgets")),
//       body: ListView(
//         children: [TextFieldSample(), CheckboxSample(), DropdownSample()],
//       ),
//     );
//   }
// }
