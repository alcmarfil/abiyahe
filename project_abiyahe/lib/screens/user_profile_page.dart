import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:project_abiyahe/common/navbar.dart';
import 'package:project_abiyahe/screens/edit_profile_page.dart';
import 'package:project_abiyahe/providers/user_provider.dart';
import 'package:project_abiyahe/providers/firebase_provider.dart';
import 'package:project_abiyahe/providers/travel_plan_provider.dart';
import 'package:project_abiyahe/screens/friends_list_page.dart';
import 'package:project_abiyahe/screens/similar_people_page.dart';
import 'package:provider/provider.dart';

class UserDetailsPage extends StatefulWidget {
  final String? targetUsername;
  final bool isReadOnly;

  const UserDetailsPage({
    super.key,
    // not required parameters
    this.targetUsername, // pass the username to the user details page
    this.isReadOnly = false, // if true, the user details page is read only
  });

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
    "Food": "assets/food_icon.png",
    "Adventure": "assets/adventure_icon.png",
    "Beach": "assets/beach_icon.png",
    "Culture": "assets/culture_icon.png",
    "Nature": "assets/nature_icon.png",
    "Relaxation": "assets/relaxation_icon.png",
  };


  List<String>? travelPreferences;
  String? hoveredInterest;
  String? pressedInterest;
  bool? isPublic;
  File? imageFile;
  bool isLoading = true;
  String? errorMessage;
  bool _isInitialized = false;
  List<String> friends = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      fetchUserDetails();
    }
  }

  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userProvider = context.read<UserProvider>();
      String? userId;

      if (widget.targetUsername != null) {
        // get user if the user id is provided
        final userData =
            await userProvider.getUserByUsername(widget.targetUsername!);
        if (userData != null) {
          // get user id
          userId = userData['userId'];
        }
      } else {
        // if no user id is provided, get the current user id
        userId = await userProvider.getCurrentUserId();
      }

      if (userId == null) {
        setState(() {
          isLoading = false;
          errorMessage = "No user logged in";
        });
        return;
      }

      // get user details
      await userProvider.getUserDetails(userId);
      final userDetails = userProvider.userDetails;

      if (userDetails != null) {
        setState(() {
          firstName = userDetails['firstName'];
          lastName = userDetails['lastName'];
          email = userDetails['email'];
          phoneNumber = userDetails['phoneNumber'];
          userName = userDetails['userName'];
          profilePictureUrl = userDetails['profilePictureUrl'];
          interests = List<String>.from(userDetails['interests'] ?? []);
          travelPreferences =
              List<String>.from(userDetails['travelPreferences'] ?? []);
          isPublic = userDetails['isPublic'] ?? true;
          friends = List<String>.from(userDetails['friends'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load user details";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error loading user details: $e";
      });
    }
  }

  Widget buildInterestsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 10) / 4; // 4 items per row + padding

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
            child: Align(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 13,
                children: interests!.map((interest) {
                  final iconPath =
                      interestsIcons[interest]; // <-- map label to img!
                  return InkWell(
                    onTapDown: (_) =>
                        setState(() => pressedInterest = interest),
                    onTapUp: (_) => setState(() => pressedInterest = null),
                    onTapCancel: () => setState(() => pressedInterest = null),
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: itemWidth,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff73c7ff),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: pressedInterest == interest
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
    final itemWidth = (screenWidth - 64 - 24) /
        2; // 2 per row, 32px padding each side, 24px spacing

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
              children: travelPreferences!.map((style) {
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
    if (widget.isReadOnly) {
      return const SizedBox.shrink();
    }
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
                    : (profilePictureUrl != null &&
                                profilePictureUrl!.isNotEmpty
                            ? NetworkImage(profilePictureUrl!)
                            : const AssetImage('assets/default_pic.jpg'))
                        as ImageProvider,
                child: null,
              ),
              if (!widget.isReadOnly)
                IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.blue, size: 18),
                ),
                onPressed: () async {
                  final snackBar = SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.camera_alt, color: Colors.blue),
                          label: Text('Camera',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await _pickImage(ImageSource.camera);
                          },
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.photo, color: Colors.blue),
                          label: Text('Gallery',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            await _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.white,
                    behavior: SnackBarBehavior.floating,
                    dismissDirection: DismissDirection.horizontal,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${firstName ?? ""} ${lastName ?? ""}",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (!widget.isReadOnly)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FriendsListPage(),
                        ),
                      );
                    },
                    child: Text(
                      "${friends.length} friend${friends.length == 1 ? "" : "s"}",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  Widget publicProfileAndFindButton({
    required bool isPublic,
    required ValueChanged<bool> onToggle,
    required VoidCallback onFindSimilar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9.2, vertical: 10.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      // const SizedBox(width: 5),
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
                    horizontal: 8,
                    vertical: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Find similar people",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xff25b1ff),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchUserDetails,
                child: Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    var selectedIndex = 3;
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
                        color: const Color(0x40797979).withOpacity(0.25),
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
                        color: const Color(0x40797979).withOpacity(0.25),
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
                    const SizedBox(height: 40),
                    profilePicture(context),
                    const SizedBox(height: 24),
                    contactInfoCard(context),
                    const SizedBox(height: 16),
                    if (interests != null && interests!.isNotEmpty)
                      buildInterestsSection(context),
                    const SizedBox(height: 16),
                    if (travelPreferences != null &&
                        travelPreferences!.isNotEmpty)
                      buildTravelStylesSection(context),
                    const SizedBox(height: 16),
                    if (!widget.isReadOnly)
                      publicProfileAndFindButton(
                        isPublic: isPublic ?? true,
                        onToggle: (val) async {
                          setState(() => isPublic = val);
                          try {
                            await context
                                .read<UserProvider>()
                                .updateUserIsPublic(val);
                          } catch (e) {
                            print(e);
                          }
                        },
                        onFindSimilar: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FindSimilarPeoplePage(),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    // Sign Out Button
                    if (!widget.isReadOnly)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          width: double.infinity,
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
                          child: TextButton.icon(
                            onPressed: () async {
                              try {
                                await context.read<TravelProvider>().signOut();
                                context.read<TravelPlanProvider>().clear();
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login', (route) => false);
                              } catch (e) {
                                print("Error signing out: $e");
                              }
                            },
                            icon: Icon(Icons.logout, color: Colors.red),
                            label: Text(
                              'Sign Out',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
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
                        if (widget.isReadOnly)
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        else
                          const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: Text(
                              '@${userName ?? ""}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (!widget.isReadOnly)
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () async {
                              final needsRefresh =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );

                              if (needsRefresh == true) {
                                fetchUserDetails();
                              }
                            },
                          )
                        else
                          const SizedBox(width: 48)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) => (index),
      ),
    );
  }
}
