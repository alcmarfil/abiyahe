import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:project_abiyahe/models/signup_values.dart';
import 'package:project_abiyahe/screens/edit_profile_page.dart';
import 'package:project_abiyahe/provider/user_provider.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatefulWidget {
  final User? user;
  const UserDetailsPage({super.key, required this.user});
  // const UserDetailsPage({super.key});

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends State<UserDetailsPage> {
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  String? userName;
  String? profilePictureUrl;
  List<String>? interests;
  final Map<String, String> interestsIcons = {
    "Food": "assets/coffee_icon.png",
    "Science": "assets/science_icon.png",
    "Music": "assets/books_icon.png",
    "Travel": "assets/travel_icon.png",
    "Art": "assets/art_icon.png",
    "Books": "assets/books_icon.png",
  };

  List<String>? travelPreferences;
  String? hoveredInterest;
  String? pressedInterest;
  bool isPublic = true;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // loadMockData();
  }



  // void loadMockData() {
  //   setState(() {
  //     firstName = "Thea";
  //     lastName = "Jones";
  //     email = "theajones@gmail.com";
  //     phoneNumber = "+63 2903 3882";
  //     username = "alcmarfil";
  //     profilePictureUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
  //     // interests = ["Coffee", "Science", "Music", "Travel", "Art"];
  //     interests = ["Coffee", "Science", "Music", "Travel", "Art", "Coffee"];

  //     travelPreferences = [
  //       "Adventure",
  //       "Relaxation",
  //       "Culture",


  //     ];
  //   });
  // }

  Future<void> fetchUserDetails() async {
    if (widget.user == null || widget.user!.userId == null) return;
    await context.read<UserProvider>().getUserDetails(widget.user!.userId!);
    final userDetails = context.read<UserProvider>().userDetails;
    if (userDetails != null) {
      setState(() {
        firstName = userDetails['firstName'];
        lastName = userDetails['lastName'];
        email = userDetails['email'];
        phoneNumber = userDetails['phoneNumber'];
        userName = userDetails['userName'] ?? widget.user?.userName;
        profilePictureUrl = userDetails['profilePictureUrl'];
        interests = List<String>.from(userDetails['interests'] ?? []);
        travelPreferences = List<String>.from(userDetails['travelPreferences'] ?? []);
      });
    }
  }

  Widget buildInterestsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =  (screenWidth-10) / 4; // 4 items per row + padding

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              "Interests",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: 
            Align(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 13,
                children:
                    interests!.map((interest) {
                      final iconPath =
                          interestsIcons[interest]; // <-- map label to img!
                      return InkWell(
                        onTapDown:
                            (_) => setState(() => pressedInterest = interest),
                        onTapUp: (_) => setState(() => pressedInterest = null),
                        onTapCancel:
                            () => setState(() => pressedInterest = null),
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(
                              horizontal:1,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xff73c7ff),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow:
                                  pressedInterest == interest
                                      ? [
                                        BoxShadow(
                                          color: const Color.fromARGB(
                                            255,
                                            169,
                                            209,
                                            241,
                                          ),
                                          blurRadius: 4,
                                          offset: Offset(1, 3),
                                        ),
                                      ]
                                      : [],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (iconPath != null)
                                  Image.asset(iconPath, width: 45, height: 45),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTravelStylesSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        (screenWidth - 64 - 24) / 2; // 2 per row, 32px padding each side, 24px spacing

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              "Travel Styles",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 13,
              children:
                  travelPreferences!.map((style) {
                    return Container(
                      width: itemWidth,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xff73c7ff),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        style,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget contactInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
        child: Column(
          children: [
            // Email
            Row(
              children: [
                const Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff73c7ff),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          email ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Phone Number
            Row(
              children: [
                const Text(
                  "Contact Number",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xff73c7ff),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.black87),
                        const SizedBox(width: 8),
                        Text(
                          phoneNumber ?? "",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget profilePicture(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, top: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                        ? NetworkImage(profilePictureUrl!)
                        : const AssetImage('assets/default_pic.jpg')) as ImageProvider,
                child: null,
              ),
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(5), 
                  child: const Icon(Icons.camera_alt, color: Colors.blue, size: 18),
                ),
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  setState(() {
                    imageFile = image == null ? null : File(image.path);
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              "${firstName ?? ""} ${lastName ?? ""}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget publicProfileAndFindButton({
    required bool isPublic,
    required ValueChanged<bool> onToggle,
    required VoidCallback onFindSimilar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.2, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
        child: Row(
          children: [
            // Switch and label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Show profile \n to public",
                        style: TextStyle(
                          color: Color(0xFF22305A),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: isPublic,
                        onChanged: onToggle,
                        activeColor: Color(0xFF4DB6FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // const Spacer(),
            Expanded(
              child: ElevatedButton(
                onPressed: onFindSimilar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff73c7ff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Find similar people",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              // Blue header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25B1FF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
              ),
              // Ellipse 3 (largest, at the back)
              Positioned(
                left: -55,
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
                left: -4,
                top: -267,
                child: Container(
                  width: 383,
                  height: 383,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF25B1FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0x40797979,
                        ).withOpacity(0.25), // #797979 25%
                        offset: const Offset(-15, 15),
                        blurRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              // Ellipse 1 (smallest, at the front)
              Positioned(
                left: 37,
                top: -267,
                child: Container(
                  width: 302,
                  height: 302,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF25B1FF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0x40797979,
                        ).withOpacity(0.25), // #797979 25%
                        offset: const Offset(-15, 15),
                        blurRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40), // padding for safe area
                    profilePicture(context),

                    const SizedBox(height: 24),
                    // Info Card
                    contactInfoCard(context),

                    const SizedBox(height: 16),
                    // Interests Section
                    buildInterestsSection(context),
                    const SizedBox(height: 16),
                    // Travel Styles Section
                    buildTravelStylesSection(context),
                    const SizedBox(height: 16),
                    // Public Profile and Find Button
                    publicProfileAndFindButton(
                      isPublic: isPublic,
                      onToggle: (val) => setState(() => isPublic = val),
                      onFindSimilar: () {
                        // action here
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // custom app bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back arrow
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        // Username
                        Expanded(
                          child: Center(
                            child: Text(
                              '@${userName ?? ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow:
                                  TextOverflow.ellipsis, //ellipsis for overflow
                            ),
                          ),
                        ),
                        // Edit icon
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () async {
                            final needsRefresh = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const EditProfilePage(),
                              ),
                            );
                            
                            if (needsRefresh == true) {
                              fetchUserDetails();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
