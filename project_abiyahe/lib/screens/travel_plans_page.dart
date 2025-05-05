import 'package:flutter/material.dart';
import 'package:project_abiyahe/common/drawer.dart';

class TravelPlansPage extends StatelessWidget {
  const TravelPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
          "Travel Plans",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          "You are in travel plans page",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}