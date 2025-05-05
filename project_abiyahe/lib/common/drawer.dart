import 'package:flutter/material.dart';
import 'package:project_abiyahe/models/signup_values.dart';
import 'package:project_abiyahe/providers/firebase_provider.dart';
import 'package:project_abiyahe/screens/profile_screen.dart';
import 'package:project_abiyahe/screens/user_profile_page.dart';
import 'package:provider/provider.dart';
import '../screens/similar_people_page.dart';
import '../screens/travel_plans_page.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              "Abiyahe",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            title: Text("Travel Plans"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => TravelPlansPage()));
            },
          ),
          ListTile(
            title: Text("Find Similar People"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => FindSimilarPeoplePage()));
            },
          ),
          ListTile(
            title: Text("Profile Page"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => UserDetailsPage()));
            },
          ),

          SizedBox(height: 300),
          ListTile(
            title: Text('Sign Out'),
            onTap: () => context.read<TravelProvider>().signOut(),
          ),
        ],
      ),
    );
  }
}