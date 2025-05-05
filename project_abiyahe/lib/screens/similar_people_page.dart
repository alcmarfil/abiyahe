import 'package:flutter/material.dart';
import 'package:project_abiyahe/common/drawer.dart';

class FindSimilarPeoplePage extends StatelessWidget {
  const FindSimilarPeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text(
          "Find Similar People",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Text(
          "You are in find similar people page",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}