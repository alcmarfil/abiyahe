import 'package:flutter/material.dart';  
import 'package:project_abiyahe/providers/travel_plan_provider.dart';  
import 'package:project_abiyahe/models/travel_plans_model.dart';  
import 'package:project_abiyahe/screens/modal_travelplan.dart';  
import 'package:project_abiyahe/screens/plan_details.dart';  
import 'package:provider/provider.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:project_abiyahe/providers/user_provider.dart';  
import 'package:project_abiyahe/common/navbar.dart';  
import 'package:project_abiyahe/screens/qr_scanner_screen.dart';  

class TravelPlansPage extends StatefulWidget {  
  const TravelPlansPage({super.key});  

  @override  
  State<TravelPlansPage> createState() => _TravelPlansPageState();  
}  

class _TravelPlansPageState extends State<TravelPlansPage> {  
  int selectedIndex = 0;  

  @override  
  void initState() {  
    super.initState();  
  }  

  @override  
  void didChangeDependencies() {  
    super.didChangeDependencies();  
    final uid = context.watch<UserProvider>().currentUserId;  
    if (uid != null) {  
      context.read<TravelPlanProvider>().fetchtravelplans(uid);  
    } 
  
  }  

  @override  
  Widget build(BuildContext context) {  
    final uid = context.watch<UserProvider>().currentUserId;  
    return Scaffold(  
      body:  
          uid == null  
              ? const Center(child: CircularProgressIndicator())  
              : StreamBuilder<List<TravelPlans>>( // CHANGED: FutureBuilder → StreamBuilder  
                  stream: context  
                      .read<TravelPlanProvider>()  
                      .getSharedTravelPlans(uid),  
                  builder: (context, sharedSnapshot) {  
                    return StreamBuilder<QuerySnapshot>(  
                      stream: context.watch<TravelPlanProvider>().travelplan,  
                      builder: (context, ownedSnapshot) {  
                        // Owned plans  
                        final ownedPlans =  
                            ownedSnapshot.hasData  
                                ? ownedSnapshot.data!.docs  
                                    .map(  
                                      (doc) => TravelPlans.fromJson(  
                                        doc.data() as Map<String, dynamic>,  
                                      ),  
                                    )  
                                    .toList()  
                                : <TravelPlans>[];  

                        // Shared plans  
                        final sharedPlans = sharedSnapshot.data ?? [];  

                        return LayoutBuilder(  
                          builder: (context, constraints) {  
                            final double parentWidth = constraints.maxWidth;  
                            return Stack(  
                              children: [  
                                Positioned(  
                                  left: 0,  
                                  right: 0,  
                                  top: 0,  
                                  child: Container(  
                                    height: 70,  
                                    color: Color(0xFF25B1FF),  
                                  ),  
                                ),  
                                // Ellipse 3 (largest, at the back)  
                                Positioned(  
                                  left: (parentWidth - 485) / 2,  
                                  top: -420,  
                                  child: Container(  
                                    width: 485,  
                                    height: 485,  
                                    decoration: BoxDecoration(  
                                      shape: BoxShape.circle,  
                                      color: const Color(0xFF25B1FF),  
                                      boxShadow: [  
                                        BoxShadow(  
                                          color: const Color(  
                                            0x29535353,  
                                          ).withOpacity(0.18),  
                                          offset: const Offset(2, 2),  
                                          blurRadius: 10,  
                                        ),  
                                      ],  
                                    ),  
                                  ),  
                                ),  
                                // Ellipse 2  
                                Positioned(  
                                  left: (parentWidth - 383) / 2,  
                                  top: -352,  
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
                                          ).withOpacity(0.25),  
                                          offset: const Offset(-15, 15),  
                                          blurRadius: 50,  
                                        ),  
                                      ],  
                                    ),  
                                  ),  
                                ),  
                                // Title row (separate)  
                                Positioned(  
                                  left: 20,  
                                  top: 28,  
                                  child: Text(  
                                    'Travel Plans',  
                                    style: TextStyle(  
                                      color: Colors.white,  
                                      fontSize: 20,  
                                      fontWeight: FontWeight.bold,  
                                    ),  
                                  ),  
                                ),  

                                Positioned(  
                                  right: 20,  
                                  top: 25,  
                                  child: Row(  
                                    children: [  
                                      IconButton(  
                                        icon: Icon(  
                                          Icons.qr_code_scanner,  
                                          color: Colors.white,  
                                        ),  
                                        onPressed: () {  
                                          Navigator.push(  
                                            context,  
                                            MaterialPageRoute(builder: (context) => QrScannerScreen()),  
                                          );  
                                        },  
                                      ),  
                                    ],  
                                  ),  
                                ),  
                                // Main content  
                                Positioned.fill(  
                                  top: 70,  
                                  child: ListView(  
                                    padding: EdgeInsets.zero,  
                                    children: [  
                                      ExpansionTile(  
                                        title: const Text(  
                                          "Owned Plans",  
                                          style: TextStyle(  
                                            fontWeight: FontWeight.bold,  
                                            fontSize: 20,  
                                          ),  
                                        ),  
                                        initiallyExpanded: true,  
                                        children:  
                                            ownedPlans.isEmpty  
                                                ? [  
                                                  const ListTile(  
                                                    title: Text(  
                                                      "No owned plans.",  
                                                    ),  
                                                  ),  
                                                ]  
                                                : ownedPlans  
                                                    .map(  
                                                      (plan) => Card(  
                                                        elevation: 2,  
                                                        shadowColor: const Color(  
                                                          0x408DBBFF,  
                                                        ),  
                                                        shape: RoundedRectangleBorder(  
                                                          borderRadius:  
                                                              BorderRadius.circular(  
                                                                18,  
                                                              ),  
                                                        ),  
                                                        margin:  
                                                            const EdgeInsets.symmetric(  
                                                              vertical: 8,  
                                                              horizontal: 16,  
                                                            ),  
                                                        child: ListTile(  
                                                          contentPadding:  
                                                              const EdgeInsets.symmetric(  
                                                                vertical: 10,  
                                                                horizontal: 16,  
                                                              ),  
                                                          title: Text(  
                                                            plan.name,  
                                                            style:  
                                                                const TextStyle(  
                                                                  fontWeight:  
                                                                      FontWeight  
                                                                          .w600,  
                                                                  fontSize: 16,  
                                                                ),  
                                                          ),  
                                                          subtitle: Text(  
                                                            plan  
                                                                    .location  
                                                                    .isNotEmpty  
                                                                ? plan.location  
                                                                : 'No location set',  
                                                            style:  
                                                                const TextStyle(  
                                                                  color:  
                                                                      Colors.grey,  
                                                                  fontSize: 14,  
                                                                ),  
                                                          ),  
                                                          trailing: Row(  
                                                            mainAxisSize:  
                                                                MainAxisSize.min,  
                                                            children: [  
                                                              if (plan.sharedWith !=  
                                                                      null &&  
                                                                  plan  
                                                                      .sharedWith!  
                                                                      .isNotEmpty)  
                                                                IconButton(  
                                                                  onPressed: () {  
                                                                    showDialog(  
                                                                      context:  
                                                                          context,  
                                                                      builder:  
                                                                          (  
                                                                            BuildContext  
                                                                            context,  
                                                                          ) => TravelPlanModal(  
                                                                            type:  
                                                                                'Shared Users',  
                                                                            item:  
                                                                                plan,  
                                                                          ),  
                                                                    );  
                                                                  },  
                                                                  icon: const Icon(  
                                                                    Icons  
                                                                        .people_outline,  
                                                                  ),  
                                                                  tooltip:  
                                                                      'View shared users',  
                                                                ),  
                                                              IconButton(  
                                                                onPressed: () {  
                                                                  showDialog(  
                                                                    context:  
                                                                        context,  
                                                                    builder:  
                                                                        (  
                                                                          BuildContext  
                                                                          context,  
                                                                        ) => TravelPlanModal(  
                                                                          type:  
                                                                              'Share',  
                                                                          item:  
                                                                              plan,  
                                                                          showQRButton: true,  
                                                                        ),  
                                                                  ).then((_) {  
                                                                    if (uid != null) {  
                                                                      context.read<TravelPlanProvider>().fetchtravelplans(uid);  
                                                                    }  
                                                                  });  
                                                                },  
                                                                icon: const Icon(  
                                                                  Icons  
                                                                      .ios_share_outlined,  
                                                                ),  
                                                              ),  
                                                              IconButton(  
                                                                onPressed: () {  
                                                                  showDialog(  
                                                                    context:  
                                                                        context,  
                                                                    builder:  
                                                                        (  
                                                                          BuildContext  
                                                                          context,  
                                                                        ) => TravelPlanModal(  
                                                                          type:  
                                                                              'Delete',  
                                                                          item:  
                                                                              plan,  
                                                                        ),  
                                                                  );  
                                                                },  
                                                                icon: const Icon(  
                                                                  Icons  
                                                                      .delete_outline_outlined,  
                                                                ),  
                                                              ),  
                                                            ],  
                                                          ),  
                                                          onTap: () {  
                                                            Navigator.pushReplacement(  
                                                              context,  
                                                              MaterialPageRoute(  
                                                                builder:  
                                                                    (context) =>  
                                                                        TravelDetails(  
                                                                          plan:  
                                                                              plan,  
                                                                        ),  
                                                              ),  
                                                            );  
                                                          },  
                                                        ),  
                                                      ),  
                                                    )  
                                                    .toList(),  
                                      ),  
                                      const SizedBox(height: 16),  
                                      ExpansionTile(  
                                        title: const Text(  
                                          "Shared Plans",  
                                          style: TextStyle(  
                                            fontWeight: FontWeight.bold,  
                                            fontSize: 20,  
                                          ),  
                                        ),  
                                        initiallyExpanded: true,  
                                        children:  
                                            sharedPlans.isEmpty  
                                                ? [  
                                                  const ListTile(  
                                                    title: Text(  
                                                      "No shared plans.",  
                                                    ),  
                                                  ),  
                                                ]  
                                                : sharedPlans  
                                                    .map(  
                                                      (plan) => Card(  
                                                        elevation: 2,  
                                                        shadowColor: const Color(  
                                                          0x408DBBFF,  
                                                        ),  
                                                        shape: RoundedRectangleBorder(  
                                                          borderRadius:  
                                                              BorderRadius.circular(  
                                                                18,  
                                                              ),  
                                                        ),  
                                                        margin:  
                                                            const EdgeInsets.symmetric(  
                                                              vertical: 8,  
                                                              horizontal: 16,  
                                                            ),  
                                                        child: ListTile(  
                                                          contentPadding:  
                                                              const EdgeInsets.symmetric(  
                                                                vertical: 10,  
                                                                horizontal: 16,  
                                                              ),  
                                                          title: Text(  
                                                            plan.name,  
                                                            style:  
                                                                const TextStyle(  
                                                                  fontWeight:  
                                                                      FontWeight  
                                                                          .w600,  
                                                                  fontSize: 16,  
                                                                ),  
                                                          ),  
                                                          subtitle: Text(  
                                                            plan  
                                                                    .location  
                                                                    .isNotEmpty  
                                                                ? plan.location  
                                                                : 'No location set',  
                                                            style:  
                                                                const TextStyle(  
                                                                  color:  
                                                                      Colors.grey,  
                                                                  fontSize: 14,  
                                                                ),  
                                                          ),  
                                                          trailing: IconButton(  
                                                            icon: const Icon(  
                                                              Icons  
                                                                  .remove_circle_outline,  
                                                              color: Colors.red,  
                                                            ),  
                                                            tooltip:  
                                                                'Remove Access',  
                                                            onPressed: () async {  
                                                              final result =  
                                                                  await showDialog<  
                                                                    bool  
                                                                  >(  
                                                                    context:  
                                                                        context,  
                                                                    builder:  
                                                                        (  
                                                                          context,  
                                                                        ) => TravelPlanModal(  
                                                                          type:  
                                                                              'Remove Access',  
                                                                          item:  
                                                                              plan,  
                                                                        ),  
                                                                  );  
                                                              if (result ==  
                                                                  true) {  
                                                                setState(() {});  
                                                              }  
                                                            },  
                                                          ),  
                                                          onTap: () {  
                                                            Navigator.pushReplacement(  
                                                              context,  
                                                              MaterialPageRoute(  
                                                                builder:  
                                                                    (context) =>  
                                                                        TravelDetails(  
                                                                          plan:  
                                                                              plan,  
                                                                        ),  
                                                              ),  
                                                            );  
                                                          },  
                                                        ),  
                                                      ),  
                                                    )  
                                                    .toList(),  
                                      ),  
                                    ],  
                                  ),  
                                ),  
                              ],  
                            );  
                          },  
                        );  
                      },  
                    );  
                  },  
                ),  
      bottomNavigationBar: CustomNavBar(  
        currentIndex: selectedIndex,  
        onTap: (index) => (index),  
      ),  
      backgroundColor: Colors.white,  
    );  
  }  
}  
