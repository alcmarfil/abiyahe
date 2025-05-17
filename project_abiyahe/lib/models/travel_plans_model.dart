import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_abiyahe/models/itinerary_model.dart';

class TravelPlans {
  final String? travelId;
  final String name;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String? accomodation;
  final String? notes;
  final String userId;
  final List<ItineraryItem>? itinerary; // Single list of activities
  final List<String>? sharedWith;
  int? reminderDaysBefore;

  TravelPlans({
    this.travelId,
    required this.name,
    required this.startDate,
    this.endDate,
    required this.location,
    this.accomodation,
    this.notes,
    required this.userId,
    this.itinerary,
    this.sharedWith,
    this.reminderDaysBefore,
  });

  // factory constructor to instantiate object from json format
  factory TravelPlans.fromJson(Map<String, dynamic> json) {
    return TravelPlans(
      travelId: json['travelId'] as String?,
      name: json['name'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: json['endDate'] != null 
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      location: json['location'] as String,
      accomodation: json['accomodation'] as String?,
      notes: json['notes'] as String?,
      userId: json['userId'] as String,
      itinerary: json['itinerary'] != null 
          ? (json['itinerary'] as List).map((item) => 
              ItineraryItem.fromJson(item as Map<String, dynamic>)
            ).toList()
          : null,
      sharedWith: json['sharedWith'] != null 
          ? (json['sharedWith'] as List).map((item) => item as String).toList()
          : null,
      reminderDaysBefore: json['reminderDaysBefore'] as int?,
    );
  }

  static List<TravelPlans> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<TravelPlans>((dynamic d) => TravelPlans.fromJson(d)).toList();
  }

  // convert to json
  Map<String, dynamic> toJson() {
    return {
      'travelId': travelId,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'accomodation': accomodation,
      'notes': notes,
      'userId': userId,
      'itinerary': itinerary?.map((item) => item.toJson()).toList(),
      'sharedWith': sharedWith,
      'reminderDaysBefore': reminderDaysBefore,
    };
  }

}