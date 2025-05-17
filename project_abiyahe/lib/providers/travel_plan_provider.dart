import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:flutter/material.dart';  
import 'package:project_abiyahe/api/firebase_travel_plan_api.dart';  
import '../../../../models/travel_plans_model.dart';  

class TravelPlanProvider with ChangeNotifier {  
  late Stream<QuerySnapshot> _travelplansStream;  
  late FirebaseTravelPlanAPI firebaseService;  
  String? _currentUserId;  

  TravelPlanProvider() {  
    firebaseService = FirebaseTravelPlanAPI();  
  }  

  // getter  
  Stream<QuerySnapshot> get travelplan => _travelplansStream;  

  void fetchtravelplans(String uid) {  
    _currentUserId = uid;  
    _travelplansStream = firebaseService.getTravelPlansByUserId(uid);  
    notifyListeners();  
  }  

  Future<String> addTravelplan(TravelPlans item) async {  
    String travelId = await firebaseService.addTravelplan(item.toJson());  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
    return travelId;  
  }  

  Future<String> editNotes({  
    required String travelId,  
    required String notes,  
  }) async {  
    String result = await firebaseService.editNotes(  
      travelId: travelId,  
      notes: notes,  
    );  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
    return result;  
  }  

  Future<String> editAccommodation({  
    required String travelId,  
    required String accommodation,  
  }) async {  
    String result = await firebaseService.editAccommodation(  
      travelId: travelId,  
      accommodation: accommodation,  
    );  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
    return result;  
  }  

  Future<void> editTravelplan({  
    required String id,  
    String? name,  
    String? location,  
    DateTime? startDate,  
    DateTime? endDate,  
  }) async {  
    try {  
      final snapshot = await firebaseService.getAlltravelplans().first;  
      TravelPlans? currenttravelplan = snapshot.docs  
          .map((doc) => TravelPlans.fromJson(doc.data() as Map<String, dynamic>))  
          .firstWhere(  
            (e) => e.travelId == id,  
            orElse: () {  
              throw Exception('Travelplan not found for id: $id');  
            },  
          );  

      String updatedName = name ?? currenttravelplan.name;  
      String updatedLocation = location ?? currenttravelplan.location;  
      DateTime updatedStartDate = startDate ?? currenttravelplan.startDate;  
      DateTime updatedEndDate = endDate ?? currenttravelplan.endDate ?? DateTime.now();  

      String message = await firebaseService.editTravelplan(  
        id: id,  
        name: updatedName,  
        location: updatedLocation,  
        startDate: updatedStartDate,  
        endDate: updatedEndDate,  
      );  

      if (_currentUserId != null) {  
        fetchtravelplans(_currentUserId!);  
      }  

      print(message);  
    } catch (e) {  
      print("Error editing travelplan: $e");  
    }  
  }  

  Future<void> deletetravelplan(String id) async {  
    String message = await firebaseService.deleteTravelplan(id);  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
    print(message);  
  }  

  Future<TravelPlans?> fetchTravelPlanById(String travelId) async {  
    return await firebaseService.getTravelPlanById(travelId);  
  }  

  Future<void> addActivity({  
    required String travelId,  
    required String activity,  
    required DateTime date,  
  }) async {  
    await firebaseService.addActivity(travelId: travelId, activity: activity, date: date);  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
  }  

  Future<void> deleteActivity({  
    required String travelId,  
    required String activity,  
    required DateTime date,  
  }) async {  
    await firebaseService.deleteActivity(travelId: travelId, activity: activity, date: date);  
    if (_currentUserId != null) {  
      fetchtravelplans(_currentUserId!);  
    }  
  }  

  Future<void> shareTravelPlan({  
    required String travelId,  
    required List<String> usernames,  
  }) async {  
    await firebaseService.shareTravelPlan(travelId: travelId, currentUserId: _currentUserId!, usernames: usernames);  
    if (_currentUserId != null) {   
      fetchtravelplans(_currentUserId!);  
    }  
  }  

    Future<void> unshareTravelPlan({
    required String travelId,
    required String userId,
  }) async {
    await firebaseService.unshareTravelPlan(travelId: travelId, userId: userId);
    if (_currentUserId != null) {
      fetchtravelplans(_currentUserId!);
    }
  }

  Stream<List<TravelPlans>> getSharedTravelPlans(String userId) {
    return firebaseService
        .getSharedTravelPlansStream(userId)
        .handleError((error) {
      print("Error fetching shared plans: $error");
    });
  }

  void clear() {
    _travelplansStream = Stream.empty();
    notifyListeners();
  }

  Future<String> editReminder({
    required String travelId,
    required int daysBefore,
  }) async {
    return await firebaseService.editReminder(
      travelId: travelId,
      daysBefore: daysBefore,
    );
  }

  Future<List<Map<String, dynamic>>> getSharedUsersDetails(
      List<String> sharedWith) async {
    return await firebaseService.getSharedUsersDetails(sharedWith);
  }

  // for QR-based sharing
  Future<void> joinTravelPlanViaQR(String travelId) async {
    final userId = _currentUserId;
    if (userId != null) {
      await firebaseService.joinTravelPlanViaQR(travelId, userId);
      fetchtravelplans(userId); // refresh plans list
    }
  }
} 
