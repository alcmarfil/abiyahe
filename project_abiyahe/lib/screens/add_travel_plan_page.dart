import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:project_abiyahe/models/travel_plans_model.dart';
import 'package:project_abiyahe/providers/travel_plan_provider.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:provider/provider.dart';
import 'package:project_abiyahe/providers/user_provider.dart';
import 'package:project_abiyahe/screens/plan_details.dart';
import 'package:project_abiyahe/config/api_config.dart';


class AddTravelPlanPage extends StatefulWidget {
  const AddTravelPlanPage({super.key});

  @override
  State<AddTravelPlanPage> createState() => _AddTravelPlanPageState();
}

class _AddTravelPlanPageState extends State<AddTravelPlanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _whereController = TextEditingController();
  final TextEditingController _accommodationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _whereController.dispose();
    _accommodationController.dispose();
    _notesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  
  /// makes an HTTP GET request to the Nominatim API to search for locations
  /// based on the user's input query. The API returns a list of matching places with their
  /// display names.
  Future<List<String>> _searchPlaces(String query) async {
    final url = Uri.parse(
      'https://us1.locationiq.com/v1/autocomplete?key=${ApiConfig.locationIqApiKey}&q=$query&format=json&limit=5',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'Flutter App'},
    );

    // check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      // parse the JSON response into a List
      final List data = json.decode(response.body);
      
      // map the response data to extract only the display_name field
      // and convert it to a List<String>
      return data
          .map<String>((place) => place['display_name'] as String)
          .toList();
    } else {
      // return empty list if request failed
      return [];
    }
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 32,
                        color: Color(0xff22305A),
                      ),
                      onPressed: () => Navigator.of(context).popAndPushNamed('/travel_plans'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Plan a new trip',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        color: Color(0xff22305A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Build an itinerary and map\nyour travel plans!',
                      style: TextStyle(
                        color: Color(0xff25b1ff),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff9cd8ff),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // here to (OpenStreetMap Autocomplete)
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff9cd8ff),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: TypeAheadField<String>( //typeahead field to search for places
                      controller: _whereController,
                      suggestionsCallback: _searchPlaces, //callback function to search for places
                      itemBuilder: (context, suggestion) {
                        return ListTile(title: Text(suggestion));
                      },
                      onSelected: (suggestion) {
                        _whereController.text = suggestion; //update the UI when selected a suggestion
                      },
                      builder: (context, controller, focusNode) { 
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Where to?',
                            hintText: 'e.g., Japan, Korea, Taiwan',
                            border: InputBorder.none,
                          ),
                        );
                      },
                      emptyBuilder: (context) => ListTile(title: Text('No places found')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dates
                  GestureDetector(
                    onTap: () => _showDateRangePickerModal(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff9cd8ff),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Dates',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (_selectedDateRange != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      getDateRangeText(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Accommodation
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff9cd8ff),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _accommodationController,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Accommodation (optional)',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Notes
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xff9cd8ff),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        labelStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            _whereController.text.isNotEmpty &&
                            _selectedDateRange != null && _nameController.text.isNotEmpty)  {
                          // valid proceed to saving 
                          final newPlan = TravelPlans(
                            name: _nameController.text.trim(),
                            startDate: _selectedDateRange!.start,
                            endDate: _selectedDateRange!.end,
                            location: _whereController.text.trim(),
                            accomodation: _accommodationController.text.trim().isEmpty ? null : _accommodationController.text.trim(),
                            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                            userId: context.read<UserProvider>().currentUserId ?? '',
                          );

                          String travelId = await context.read<TravelPlanProvider>().addTravelplan(newPlan);
                          final fetchedPlan = await context.read<TravelPlanProvider>().fetchTravelPlanById(travelId);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TravelDetails(plan: fetchedPlan!),
                            ),
                          );
                           

                        } else if (_whereController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a destination'),
                            ),
                          );
                        } else if (_selectedDateRange == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a date range'),
                            ),
                          );
                        } else if (_nameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please put a trip name!'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff25b1ff),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Start Planning'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
