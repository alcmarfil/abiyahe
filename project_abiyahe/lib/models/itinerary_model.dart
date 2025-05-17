import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryItem {
  final String activity;
  final DateTime date;

  ItineraryItem({
    required this.activity,
    required this.date,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'activity': activity,
      'date': date,
    };
  }

  // Create from JSON
  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      activity: json['activity'] as String,
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  // Create from Firestore document
  factory ItineraryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItineraryItem.fromJson(data);
  }
} 