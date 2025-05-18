import 'package:project_abiyahe/firebase_options.dart';
import 'package:project_abiyahe/providers/friends_provider.dart';
import 'package:project_abiyahe/screens/add_travel_plan_page.dart';
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
import 'package:project_abiyahe/providers/travel_plan_provider.dart';
import 'package:project_abiyahe/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize the notification service
  await LocalNotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TravelProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TravelPlanProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor:  Color(0xff25b1ff)),
        appBarTheme: AppBarTheme(
          color: Color(0xff25b1ff),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
      initialRoute: '/signup',
      home: Consumer<TravelProvider>(
        builder: (context, authProvider, _) {
          return StreamBuilder(
            stream: authProvider.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasData) {
                return const TravelPlansPage();
              }
              
              return const Login();
            },
          );
        },
      ),
      routes: {
        '/signup': (context) => SignUp(),
        '/login': (context) => Login(),
        '/travel_plans': (context) => const TravelPlansPage(),
        '/similar_people': (context) => FindSimilarPeoplePage(),
        '/profile': (context) => UserDetailsPage(),
        '/add-travel-plan': (context) => AddTravelPlanPage(),
      },
    );
  }
}
