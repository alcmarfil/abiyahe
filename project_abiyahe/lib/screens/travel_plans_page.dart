import 'package:flutter/material.dart';
import 'package:project_abiyahe/common/drawer.dart';
import 'package:project_abiyahe/providers/firebase_provider.dart';
import 'package:provider/provider.dart';

class TravelPlansPage extends StatelessWidget {
  const TravelPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text("Travel Plans", style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "You are in travel plans page",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<TravelProvider>(context, listen: false).signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}