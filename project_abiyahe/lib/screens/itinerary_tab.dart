import 'package:flutter/material.dart';
import 'package:project_abiyahe/models/travel_plans_model.dart';
import 'package:intl/intl.dart';
import 'package:project_abiyahe/screens/modal_travelplan.dart';

class ItineraryTab extends StatefulWidget {
  final TravelPlans plan;
  final VoidCallback onActivityAdded; //void function to refresh
  final bool isOwner;

  const ItineraryTab({super.key, required this.plan, required this.onActivityAdded, required this.isOwner});

  @override
  State<ItineraryTab> createState() => _ItineraryTabState();
}

class _ItineraryTabState extends State<ItineraryTab> {
  DateTime? selectedDate;

  List<DateTime> getDatesInRange(DateTime start, DateTime? end) { //get dates in range
    final endDate = end ?? start;
    List<DateTime> dates = [];
    for (int i = 0; i <= endDate.difference(start).inDays; i++) { //loop through each day in the range
      dates.add(DateTime(start.year, start.month, start.day + i)); //add each date to the list
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final tripDates = getDatesInRange(widget.plan.startDate, widget.plan.endDate); //get dates in range
    final itinerary = widget.plan.itinerary ?? []; //get itinerary
    final dateFormat = DateFormat('E, M/d'); //format date

    // filter dates
    final datesToShow = selectedDate == null
        ? tripDates
        : tripDates.where((d) =>
            d.year == selectedDate!.year &&
            d.month == selectedDate!.month &&
            d.day == selectedDate!.day).toList();

    return Column(
      children: [
        // Dropdown filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFFd3eaff), 
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff25b1ff).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<DateTime?>(
                value: selectedDate,
                hint: const Text('Filter by date'),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Color(0xff25b1ff)),
                dropdownColor: Colors.white,
                style: const TextStyle(
                  color: Color(0xff22305A),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                items: [
                  DropdownMenuItem<DateTime?>(
                    value: null,
                    child: const Text('All Dates'),
                  ),
                  ...tripDates.map((date) => DropdownMenuItem<DateTime?>( //map each date to a dropdown menu item 
                        value: date,
                        child: Text(dateFormat.format(date)),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedDate = value;
                  });
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: datesToShow.length, //get the number of dates to show 
            itemBuilder: (context, index) {
              final date = datesToShow[index];
              final activitiesForDate = itinerary
                  .where((item) => 
                      item.date.year == date.year &&
                      item.date.month == date.month &&
                      item.date.day == date.day)
                  .toList(); //get the activities for the date

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xff22305A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (activitiesForDate.isNotEmpty)
                      ...activitiesForDate.map(
                        (item) => Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Color(0xFFd3eaff),
                          child: ListTile(
                            title: Text(
                              item.activity,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            trailing: widget.isOwner
                                ? IconButton(
                                    onPressed: () async {
                                      final needsRefresh = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => TravelPlanModal(
                                          type: 'Delete Activity',
                                          item: widget.plan,
                                          activity: item.activity,
                                          activityDate: item.date,
                                        ),
                                      );
                                      if (needsRefresh == true) {
                                        widget.onActivityAdded(); //call parent's function to  refresh
                                      }
                                    },
                                    icon: const Icon(Icons.delete, color: Color(0xff25b1ff)),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    if (widget.isOwner)
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFd3eaff),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ListTile(
                          title: const Text('Add Activity'),
                          trailing: const Icon(Icons.add_circle_outline, color: Color(0xff25b1ff)),
                          onTap: () async {
                            final needsRefresh = await showDialog<bool>(
                              context: context,
                              builder: (context) => TravelPlanModal(
                                type: 'Add Activity',
                                item: widget.plan,
                                activityDate: date,
                              ),
                            );
                            if (needsRefresh == true) {
                              widget.onActivityAdded(); //call parent's function to  refresh
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
