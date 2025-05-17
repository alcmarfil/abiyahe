import 'package:flutter/material.dart';
import 'package:project_abiyahe/models/travel_plans_model.dart';
import 'package:intl/intl.dart';
import 'package:project_abiyahe/screens/modal_travelplan.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/travel_plan_provider.dart';
import 'package:project_abiyahe/screens/itinerary_tab.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_abiyahe/providers/user_provider.dart';
import 'package:project_abiyahe/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class PlanHeader extends StatelessWidget {
  final String locationName;
  const PlanHeader({super.key, required this.locationName});

  Future<String?> fetchImageUrl(String query) async {
    //fetch image url using unsplash api
    final url = Uri.parse(
      'https://api.unsplash.com/search/photos?query=$query&client_id=e3JrbfAh4WtmjQZriPQfmVICktBylK_ku8dM8TbpvzQ',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['urls']['regular'];
      }
    }
    return null; // not recognized
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchImageUrl(locationName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 140,
            width: double.infinity,
            color: const Color(0xff25b1ff),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          // Show image
          return Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(snapshot.data!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(height: 140, width: double.infinity),
            ],
          );
        }
        // Not recognized, show blue
        return Container(
          height: 140,
          width: double.infinity,
          color: const Color(0xff25b1ff),
        );
      },
    );
  }
}

class TravelDetails extends StatefulWidget {
  final TravelPlans plan;
  const TravelDetails({super.key, required this.plan});

  @override
  State<TravelDetails> createState() => _TravelDetailsState();
}

class _TravelDetailsState extends State<TravelDetails>
    with SingleTickerProviderStateMixin {
  //ticker - obj that calls a callback once per animation frame
  late TabController _tabController;
  late TextEditingController _accommodationController;
  late TextEditingController _notesController;
  late TravelPlans _currentPlan;
  var selectedIndex = 0;
  int? _reminderDaysBefore;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _tabController = TabController(
      length: 2,
      vsync: this, //needs a ticker provider to work
    ); //creates a controller for two tabs allowing to switch
    //vsync used to manage animations and transitions
    _accommodationController = TextEditingController(
      text: _currentPlan.accomodation ?? '',
    );
    _notesController = TextEditingController(text: _currentPlan.notes ?? '');
    _reminderDaysBefore = _currentPlan.reminderDaysBefore;
    LocalNotificationService().requestPostNotificationPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String getDateRangeText() {
    final dateFormatter = DateFormat('MMM d, yyyy');
    if (_currentPlan.endDate == null) {
      return dateFormatter.format(_currentPlan.startDate);
    } else {
      return '${dateFormatter.format(_currentPlan.startDate)} - ${dateFormatter.format(_currentPlan.endDate!)}';
    }
  }

  //refresh plan after editing
  Future<void> refreshPlan() async {
    final updatedPlan = await context
        .read<TravelPlanProvider>()
        .fetchTravelPlanById(_currentPlan.travelId!);
    if (updatedPlan != null) {
      setState(() {
        _currentPlan = updatedPlan;
        _reminderDaysBefore = updatedPlan.reminderDaysBefore;
      });
    }
  }

  Future<int?> pickDaysBefore(
    BuildContext context, {
    int initialValue = 1,
  }) async {
    int selectedDays = initialValue;
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Remind me before...',
            style: TextStyle(
              color: Color(0xff25b1ff),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: DropdownButton<int>(
            value: selectedDays,
            dropdownColor: Colors.white,
            style: TextStyle(color: Color(0xff22305A)),
            items:
                List.generate(14, (index) => index + 1)
                    .map(
                      (days) => DropdownMenuItem(
                        value: days,
                        child: Text(
                          '$days day${days > 1 ? 's' : ''}',
                          style: TextStyle(color: Color(0xff22305A)),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                selectedDays = value;
                Navigator.of(context).pop(selectedDays);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel', style: TextStyle(color: Color(0xff22305A))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<UserProvider>().currentUserId;
    final isOwner = _currentPlan.userId == currentUserId;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top section
          Stack(
            children: [
              // blue background or image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: PlanHeader(locationName: _currentPlan.location),
              ),
              // Card
              Container(
                margin: const EdgeInsets.only(
                  top: 60, // Push down to overlap blue
                  left: 16,
                  right: 16,
                  bottom: 0,
                ),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x29535353).withOpacity(0.18),
                      offset: const Offset(2, 2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentPlan.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Color(0xff22305A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentPlan.location.isNotEmpty
                          ? _currentPlan.location
                          : 'location placeholder',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xff22305A),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            getDateRangeText(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Color(0xff22305A),
                            ),
                          ),
                        ),
                        if (isOwner)
                          IconButton(
                            onPressed: () async {
                              final needsRefresh = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => TravelPlanModal(
                                      type: 'Edit',
                                      item: _currentPlan,
                                    ),
                              );
                              if (needsRefresh == true) {
                                // fetch the updated plan
                                await refreshPlan();
                              }
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Color(0xff22305A),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // home button
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.home, color: Color(0xff22305A), size: 20),
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/travel_plans');
                    },
                    padding: EdgeInsets.all(0),
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
              // notification reminder button
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  width: 33,
                  height: 33,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications_active,
                      color: Color(0xff22305A),
                      size: 20,
                    ),
                    onPressed: () async {
                      // get the initial value from the provider
                      final int initialDays = _reminderDaysBefore ?? 1;

                      // show the dialog to pick the days before
                      final int? daysBefore = await pickDaysBefore(
                        context,
                        initialValue: initialDays,
                      );

                      if (daysBefore == null) return;

                      // set the state to update the local state
                      setState(() {
                        _reminderDaysBefore = daysBefore;
                      });

                      // o update Firestore
                      await context.read<TravelPlanProvider>().editReminder(
                        travelId: _currentPlan.travelId!,
                        daysBefore: daysBefore,
                      );

                      print(
                        'Notification scheduled for: ${daysBefore.toString()}',
                      );

                      final now = DateTime.now();

                      // schedule the notification
                      final scheduledDate = _currentPlan.startDate.subtract(
                        Duration(minutes: daysBefore),
                      ); 

                      final tzDateTime = tz.TZDateTime(
                        tz.local,
                        scheduledDate.year,
                        scheduledDate.month,
                        scheduledDate.day,
                        scheduledDate.hour,
                        scheduledDate.minute,
                        scheduledDate.second,
                      );

                      print(
                        'tzDateTime runtimeType: ${tzDateTime.runtimeType}',
                      );
                      print('Current time: $now');
                      print('Scheduled time: $tzDateTime');
                      print(
                        'Is scheduled time in the past? ${tzDateTime.isBefore(now)}',
                      );
                      await LocalNotificationService().scheduleNotification(
                        id: _currentPlan.travelId.hashCode,
                        title: 'Trip Reminder',
                        body: 'Your trip "${_currentPlan.name}" is coming up!',
                        scheduledDate: tzDateTime,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reminder set for $daysBefore days before your trip!',
                          ),
                          backgroundColor: Color(0xff25b1ff),
                        ),
                      );
                    },
                    padding: EdgeInsets.all(0),
                    constraints: BoxConstraints(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xff25b1ff),
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xff25b1ff),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [Tab(text: 'Details'), Tab(text: 'Itinerary')],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Details Tab
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Accommodation Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x408DBBFF), // 25% opacity
                              offset: const Offset(24, 20),
                              blurRadius: 70,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xffd3eaff),
                            width: 1.6,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Accommodation',
                                style: TextStyle(
                                  color: Color(0xff25b1ff),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _accommodationController,
                                decoration: InputDecoration(
                                  hintText: "Add accommodation..",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 16),
                                onChanged:
                                    isOwner
                                        ? (value) {
                                          final travelId =
                                              _currentPlan.travelId;
                                          if (travelId != null) {
                                            Provider.of<TravelPlanProvider>(
                                              context,
                                              listen: false,
                                            ).editAccommodation(
                                              travelId: travelId,
                                              accommodation: value,
                                            );
                                          } else {
                                            print('Travel ID is null!');
                                          }
                                        }
                                        : null,
                                readOnly: !isOwner,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notes Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x408DBBFF), // 25% opacity
                              offset: const Offset(24, 20),
                              blurRadius: 70,
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xffd3eaff),
                            width: 1.6,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notes',
                                style: TextStyle(
                                  color: Color(0xff25b1ff),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  hintText: "Write your notes here...",
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 16),
                                onChanged:
                                    isOwner
                                        ? (value) {
                                          print(value);
                                          Provider.of<TravelPlanProvider>(
                                            context,
                                            listen: false,
                                          ).editNotes(
                                            travelId: _currentPlan.travelId!,
                                            notes: value,
                                          );
                                        }
                                        : null,
                                readOnly: !isOwner,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Itinerary Tab
                ItineraryTab(
                  plan: _currentPlan,
                  onActivityAdded: refreshPlan,
                  isOwner: isOwner,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
