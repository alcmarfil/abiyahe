import 'package:flutter/material.dart';
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
          )
        ],
      ),
    );
  }
}