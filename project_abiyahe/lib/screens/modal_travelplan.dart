import 'package:flutter/material.dart';
import 'package:project_abiyahe/screens/qr_code_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/models/travel_plans_model.dart';
import 'package:project_abiyahe/providers/travel_plan_provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:project_abiyahe/providers/user_provider.dart';
import 'package:project_abiyahe/api/firebase_travel_plan_api.dart';

class TravelPlanModal extends StatefulWidget {
  final String type;
  final TravelPlans? item;
  final DateTime? date;
  final DateTime? activityDate;
  final String? activity;
  final List<String>? usernames;
  final bool showQRButton; // Added this parameter
  const TravelPlanModal({
    super.key, 
    required this.type, 
    this.item, 
    this.date, 
    this.activityDate, 
    this.activity, 
    this.usernames,
    this.showQRButton = false, // Default to false
  });

  @override
  State<TravelPlanModal> createState() => _TravelPlanModalState();
}

class _TravelPlanModalState extends State<TravelPlanModal> {
  final TextEditingController _formFieldController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _formFieldController.text = widget.item!.name;
      _locationController.text = widget.item!.location;
      _selectedDateRange = DateTimeRange(
        start: widget.item!.startDate,
        end: widget.item!.endDate ?? widget.item!.startDate,
      );
    }
  }

  @override
  void dispose() {
    _formFieldController.dispose();
    _locationController.dispose();
    _activityController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  String getDateRangeText() {
    if (_selectedDateRange == null) return '';
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(_selectedDateRange!.start)} - ${formatter.format(_selectedDateRange!.end)}';
  }

  Future<void> _showDateRangePickerModal(BuildContext context) async {
    DateTime? tempStart = _selectedDateRange?.start;
    DateTime? tempEnd = _selectedDateRange?.end;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: _selectedDateRange != null
                    ? PickerDateRange(_selectedDateRange!.start, _selectedDateRange!.end)
                    : null,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final range = args.value as PickerDateRange;
                    tempStart = range.startDate;
                    tempEnd = range.endDate;
                  }
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (tempStart != null && tempEnd != null) {
                    setState(() {
                      _selectedDateRange = DateTimeRange(start: tempStart!, end: tempEnd!);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Select'),
              ),
            ],
          ),
        );
      },
    );
  }

  Text _buildTitle() {
    switch (widget.type) {
      case 'Details':
        return const Text("Details");
      case 'Edit':
        return const Text("Edit travel plan");
      case 'Delete':
        return const Text("Delete travel plan");
      case 'Add Activity':
        return const Text("Add Activity");
      case 'Delete Activity':
        return const Text("Delete Activity");
      case 'Share':
        return const Text("Share travel plan");
      case 'Remove Access':
        return const Text("Remove Access");
      case 'Shared Users':
        return const Text("Shared Users");
      default:
        return const Text("");
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case 'Delete':
        return Text("Are you sure you want to delete '${widget.item!.name}'?");
      case 'Details':
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${widget.item?.name ?? 'No name available'}"),
            const SizedBox(height: 8),
            Text("Location: ${widget.item?.location ?? 'None'}"),
            const SizedBox(height: 8),
            Text("Dates: ${getDateRangeText()}"),
          ],
        );
      case 'Shared Users':
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.item?.sharedWith == null
              ? Future.value([])
              : context.read<TravelPlanProvider>().getSharedUsersDetails(widget.item!.sharedWith!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data!.map((user) => ListTile(
                title: Text(user['username'] ?? 'Unknown User'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () async {
                    await context.read<TravelPlanProvider>().unshareTravelPlan(
                      travelId: widget.item!.travelId!,
                      userId: user['userId'],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed access for ${user['username']}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(true);
                  },
                ),
              )).toList(),
            );
          },
        );
      case 'Edit':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _formFieldController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Location',
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showDateRangePickerModal(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDateRange != null ? getDateRangeText() : 'Select dates',
                        style: TextStyle(
                          color: _selectedDateRange != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Color(0xff25b1ff)),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Add Activity':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _activityController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(), 
                labelText: 'Activity',
              ),
            ),
          ],
        );
      case 'Delete Activity':
        return const Text("Are you sure you want to delete this activity?");
     
      case 'Share':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter friend\'s username',
              ),
            ),
            if (widget.showQRButton) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close modal
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QrCodeScreen(
                        travelId: widget.item!.travelId!,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        );
      case 'Remove Access':
        return const Text('Are you sure you want to remove your access to this shared plan?');
      default:
        return const SizedBox.shrink();
    }
  }

  TextButton _dialogAction(BuildContext context) {
    return TextButton(
      onPressed: () async {
        switch (widget.type) {
          case 'Delete':
            context.read<TravelPlanProvider>().deletetravelplan(widget.item!.travelId!);
            Navigator.of(context).pop(true);
            break;
          case 'Edit':
            if (_formFieldController.text.isNotEmpty && 
                _locationController.text.isNotEmpty && 
                _selectedDateRange != null) {
              context.read<TravelPlanProvider>().editTravelplan(
                id: widget.item!.travelId!,
                name: _formFieldController.text,
                location: _locationController.text,
                startDate: _selectedDateRange!.start,
                endDate: _selectedDateRange!.end,
              );
              Navigator.of(context).pop(true);
            }
            break;
          case 'Add Activity':
            if (_activityController.text.isNotEmpty && widget.activityDate != null) {
              context.read<TravelPlanProvider>().addActivity(
                travelId: widget.item!.travelId!,
                activity: _activityController.text,
                date: widget.activityDate!,
              );
              Navigator.of(context).pop(true);
            }
            break;

          case 'Delete Activity':
            context.read<TravelPlanProvider>().deleteActivity(
              travelId: widget.item!.travelId!,
              activity: widget.activity!,
              date: widget.activityDate!,
            );
            Navigator.of(context).pop(true);
            break;

          case 'Share':
            final usernames = usernameController.text.split(',').map((s) => s.trim()).toList();
            await context.read<TravelPlanProvider>().shareTravelPlan(
              travelId: widget.item!.travelId!,
              usernames: usernames,
            );
            final currentUserId = context.read<UserProvider>().currentUserId;
            final userDoc = await FirebaseTravelPlanAPI.db.collection('Users').doc(currentUserId).get();
            final friends = List<String>.from(userDoc.data()?['friends'] ?? []);
            final validUsernames = usernames.where((u) => friends.contains(u)).toList();
            if (validUsernames.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No valid friends to share with.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Travel plan shared with: ${validUsernames.join(', ')}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
            break;

          case 'Remove Access':
            final userId = context.read<UserProvider>().currentUserId;
            if (userId != null && widget.item != null) {
              await context.read<TravelPlanProvider>().unshareTravelPlan(
                travelId: widget.item!.travelId!,
                userId: userId,
              );
            }
            Navigator.of(context).pop(true);
            break;

          case 'Shared Users':         
            Navigator.of(context).pop();
            break;
        }
      },
      style: TextButton.styleFrom(
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Text(widget.type == 'Remove Access' ? 'Remove' : widget.type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<UserProvider>().currentUserId;
    final isOwner = widget.item != null && widget.item!.userId == currentUserId;

    // if (widget.type == 'Shared Users') {
    //   return Dialog(
    //     backgroundColor: Colors.white,
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(20),
    //     ),
    //     child: Container(
    //       width: 200,
    //       height: 200,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: _buildTitle(),
    //           ),
    //           Expanded(
    //             child: SingleChildScrollView(
    //               child: Padding(
    //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //                 child: _buildContent(context),
    //               ),
    //             ),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.all(8.0),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 TextButton(
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                   child: const Text("Cancel"),
    //                   style: TextButton.styleFrom(
    //                     textStyle: Theme.of(context).textTheme.labelLarge,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: _buildTitle(),
      titleTextStyle: TextStyle(color: Color(0xff25b1ff), fontSize: 20, fontWeight: FontWeight.bold),
      content: _buildContent(context),
      contentTextStyle: TextStyle(color: Color(0xff22305A)),
      actions: <Widget>[
        if (isOwner && (widget.type == 'Delete' || widget.type == 'Edit' || widget.type == 'Add Activity' || widget.type == 'Delete Activity' || widget.type == 'Share')) _dialogAction(context),
        if (!isOwner && (widget.type == 'Delete' || widget.type == 'Edit' || widget.type == 'Add Activity' || widget.type == 'Delete Activity' || widget.type == 'Share' || widget.type == 'Remove Access')) _dialogAction(context),
        if (!isOwner && (widget.type == 'Delete' || widget.type == 'Edit' || widget.type == 'Add Activity' || widget.type == 'Delete Activity' || widget.type == 'Share') && widget.type != 'Remove Access')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'You do not have permission to edit this shared plan.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ],
    );
  }
}
