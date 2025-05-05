// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/provider/firebase_provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   Map<String, dynamic>? userData;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   Future<void> fetchUserData() async {
//     final userId =
//         Provider.of<TravelProvider>(context, listen: false).user?.uid;
//     if (userId != null) {
//       try {
//         final doc =
//             await FirebaseFirestore.instance
//                 .collection("Users")
//                 .doc(userId)
//                 .get();
//         if (doc.exists) {
//           setState(() {
//             userData = doc.data();
//           });
//         } else {
//           print("User document does not exist.");
//         }
//       } catch (e) {
//         print("Error fetching user data: $e");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Home")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Welcome to the Home Screen!"),
//             Text("Username: ${userData?['userName']}"),
//             Text("Email: ${userData?['email']}"),
//             Text("First Name: ${userData?['firstName']}"),
//             Text("Last Name: ${userData?['lastName']}"),
//             const SizedBox(height: 15),
//             Container(
//               height: 100,
//               width: 100,
//               child: Center(
//                 child: Image.asset('images/test.png', fit: BoxFit.cover),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Provider.of<TravelProvider>(context, listen: false).signOut();
//                 Navigator.of(context).pushReplacementNamed('/login');
//               },
//               child: Text("Logout"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
