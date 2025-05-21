import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? profilePictureUrl;
  File? imageFile;

  // sets to track selected interests and styles
  final Set<String> selectedInterests = {};
  final Set<String> selectedTravelPreferences = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    final userProvider = context.read<UserProvider>();
    final userDetails = userProvider.userDetails;
    
    if (userDetails != null) {
      setState(() {
        _firstNameController.text = userDetails['firstName'] ?? '';
        _lastNameController.text = userDetails['lastName'] ?? '';
        _phoneNumberController.text = userDetails['phoneNumber'] ?? '';
        profilePictureUrl = userDetails['profilePictureUrl'];
        
        // get interests
        final List<dynamic> interestsList = userDetails['interests'] ?? [];
        selectedInterests.clear();
        selectedInterests.addAll(interestsList.map((e) => e.toString()));
        
        // load travel preferences
        final List<dynamic> travelPrefsList = userDetails['travelPreferences'] ?? [];
        selectedTravelPreferences.clear();
        selectedTravelPreferences.addAll(travelPrefsList.map((e) => e.toString()));
      });
    }
  }

  // Lists of available options
  List<String> interests = [
    "Adventure",
    "Beach",
    "Culture",
    "Food",
    "Nature",
    "Relaxation",
  ];
  List<String> travelPreferences = [
    "Budget",
    "Luxury",
    "Solo",
    "Family",
    "Group",
    "Couple",
  ];


  final labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Color(0xFF3A4A66),
  );

  Widget createTextFormField({
    required controller,
    required String colorHex,
    required TextInputType inputType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Color.fromARGB(255, 199, 230, 251), // Background color
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      ),
      validator: validator,
    );
  }

  Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Fixed width
        height: 35,  // Fixed height
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: EdgeInsets.only(right: 8, bottom: 5),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xff9cd8ff) : Color.fromARGB(255, 75, 116, 144).withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget createEditButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState?.save();
                      

            try {
              final userDetails = context.read<UserProvider>().userDetails;
              
              await context.read<UserProvider>().editUser(
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                phoneNumber: _phoneNumberController.text.trim(),
                email: userDetails?['email'] ?? '',
                userName: userDetails?['userName'] ?? '',
                profilePictureUrl: profilePictureUrl,
                interests: selectedInterests.toList(),
                travelPreferences: selectedTravelPreferences.toList(),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Color.fromARGB(255, 22, 90, 128),
                ),
              );

              Navigator.pop(context, true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating profile: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xff73c7ff)),
        child: Text(
          "Edit",
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff25b1ff), // Blue background
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            // Back and title row
            Row(
              children: [
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Edit profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 48), // To balance IconButton spacing
              ],
            ),
            SizedBox(height: 20),
            // Avatar
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                              ? NetworkImage(profilePictureUrl!)
                              : const AssetImage('assets/default_pic.jpg')) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final snackBar = SnackBar(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.camera_alt, color: Colors.blue),
                                label: Text('Camera', style: TextStyle(color: Colors.blue)),
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  await _pickImage(ImageSource.camera);
                                },
                              ),
                              TextButton.icon(
                                icon: Icon(Icons.photo, color: Colors.blue),
                                label: Text('Gallery', style: TextStyle(color: Colors.blue)),
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
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Form container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "First name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF3A4A66),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: createTextFormField(
                            controller: _firstNameController,
                            inputType: TextInputType.text,
                            colorHex: "0xFFd3eaff",
                            validator: (textvalue) {
                              if (textvalue == null || textvalue.isEmpty) {
                                return ("First name is required!");
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Last name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF3A4A66),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: createTextFormField(
                            controller: _lastNameController,
                            inputType: TextInputType.text,
                            colorHex: "0xFFd3eaff",
                            validator: (textvalue) {
                              if (textvalue == null || textvalue.isEmpty) {
                                return ("Last name is required!");
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Phone number",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF3A4A66),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: createTextFormField(
                            controller: _phoneNumberController,
                            inputType: TextInputType.phone,
                            colorHex: "0xFFd3eaff",
                            validator: (textvalue) {
                              if (textvalue == null || textvalue.isEmpty) {
                                return null; // Allow empty values
                              }
                              // regex for phone number
                              final phoneRegex = RegExp(r'^(09|\+639)\d{9}$');
                              if (!phoneRegex.hasMatch(textvalue)) {
                                return "Please enter a valid phone number \n (e.g., 09123456789)";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text("Interests", style: labelStyle),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: interests.map((interest) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: buildToggleButton(
                          interest,
                          selectedInterests.contains(interest),
                          () => setState(() {
                            if (selectedInterests.contains(interest)) {
                              selectedInterests.remove(interest);
                            } else {
                              selectedInterests.add(interest);
                            }
                          }),
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: 20),
                    Text("Travel Preferences", style: labelStyle),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 10,
                      children: travelPreferences.map((style) => SizedBox(
                        width: (MediaQuery.of(context).size.width - 80) / 3,
                        child: buildToggleButton(
                          style,
                          selectedTravelPreferences.contains(style),
                          () => setState(() {
                            if (selectedTravelPreferences.contains(style)) {
                              selectedTravelPreferences.remove(style);
                            } else {
                              selectedTravelPreferences.add(style);
                            }
                          }),
                        ),
                      )).toList(),
                    ),
                    SizedBox(height: 30),
                    createEditButton(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
