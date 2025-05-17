import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:project_abiyahe/models/travel_plans_model.dart';  

class FirebaseTravelPlanAPI {  
  //access the collections  
  static final FirebaseFirestore db = FirebaseFirestore.instance;  

  Stream<QuerySnapshot> getAlltravelplans() {  
    return db.collection('travelplans').snapshots(); //returns a stream object  
  }  

  Stream<QuerySnapshot> getTravelPlansByUserId(String uid) {  
    return db  
        .collection('travelplans')  
        .where('userId', isEqualTo: uid)  
        .orderBy('startDate', descending: false)  
        .snapshots();  
  }  

  Future<String> addTravelplan(Map<String, dynamic> travelplan) async {  
    try {  
      travelplan['travelId'] = db.collection('travelplans').doc().id;  
      await db  
          .collection('travelplans')  
          .doc(travelplan['travelId'])  
          .set(travelplan);  
      return travelplan['travelId'];  
    } on FirebaseException catch (e) {  
      return 'Error on ${e.message}';  
    }  
  }  

  Future<String> deleteTravelplan(String id) async {  
    try {  
      await db.collection('travelplans').doc(id).delete();  
      return 'Successfully deleted travelplan!';  
    } on FirebaseException catch (e) {  
      return 'Error on ${e.message}';  
    }  
  } //can also be void  

  Future<String> editNotes({  
    required String travelId,  
    required String notes,  
  }) async {  
    try{  
    await db.collection('travelplans').doc(travelId).update({'notes': notes});  
    return "Successfully edited notes!";  
  } on FirebaseException catch (e) {  
      return 'Error: ${e.message}';  
  }  
}  

  Future<String> editAccommodation({  
    required String travelId,  
    required String accommodation,  
  }) async {  
    try{  
    await db.collection('travelplans').doc(travelId).update({'accomodation': accommodation});  
    return "Successfully edited notes!";  
  } on FirebaseException catch (e) {  
      return 'Error: ${e.message}';  
  }  
}  

  Future<String> editTravelplan({  
    required String id,  
    required String name,  
    required String location,  
    required DateTime startDate,  
    required DateTime endDate,  
  }) async {  
    try {  
      //update the attributes  
      await db.collection('travelplans').doc(id).update({  
        'name': name,  
        'location': location,   
        'startDate': startDate,  
        'endDate': endDate,  
      });  

      return 'Successfully edited travelplan!';  
    } on FirebaseException catch (e) {  
      return 'Error: ${e.message}';  
    }  
  }  

    Future<TravelPlans?> getTravelPlanById(String travelId) async {  
    final doc = await db.collection('travelplans').doc(travelId).get();  
    if (doc.exists) {  
      return TravelPlans.fromJson(doc.data()!);  
    }  
    return null;  
  }  

  Future<void> addActivity({  
    required String travelId,  
    required String activity,  
    required DateTime date,  
  }) async {  
    await db.collection('travelplans').doc(travelId).update({  
      'itinerary': FieldValue.arrayUnion([  
        {  
          'activity': activity,  
          'date': Timestamp.fromDate(date), //timestamp is used to store date and time info in firebase  
        }  
      ])  
    });  
  }  

  Future<void> deleteActivity({  
    required String travelId,  
    required String activity,  
    required DateTime date,  
  }) async {  
    await db.collection('travelplans').doc(travelId).update({  
      'itinerary': FieldValue.arrayRemove([  
        {  
          'activity': activity,  
          'date': Timestamp.fromDate(date), // need to convert date to timestamp  
        }  
      ])  
    });  
  } //array remove removes from the array  

  //helper function to get userIds from usernames  
  Future<List<String>> getUserIdsFromUsernames(List<String> usernames) async {  
    List<String> userIds = [];  
    for (String username in usernames) {  
      final query = await db.collection('Users').where('userName', isEqualTo: username).limit(1).get();  
      if (query.docs.isNotEmpty) {  
        userIds.add(query.docs.first.id);   
      }  
    }  
    return userIds;  
  }  

  /// share a travel plan with a list of usernames  
  Future<void> shareTravelPlan({  
    required String travelId,  
    required String currentUserId,  
    required List<String> usernames,  
  }) async {  
    // fetch the current user's friends list from Firestore  
    final userDoc = await db.collection('Users').doc(currentUserId).get();  
    final friends = List<String>.from(userDoc.data()?['friends'] ?? []);  

    //only keep usernames that are in the friends list  
    final validUsernames = usernames.where((u) => friends.contains(u)).toList();  
    if (validUsernames.isEmpty) {  
      return;  
    }  
    final userIds = await getUserIdsFromUsernames(validUsernames);  
    await db.collection('travelplans').doc(travelId).update({'sharedWith': FieldValue.arrayUnion(userIds)});  
  }  

  /// unshare a travel plan with a user (remove access from a user)  
  Future<void> unshareTravelPlan({  
    required String travelId,  
    required String userId,  
  }) async {  
    await db.collection('travelplans').doc(travelId).update({'sharedWith': FieldValue.arrayRemove([userId])});  
  }  

  // NEW METHOD ADDED HERE  
  Future<void> joinTravelPlanViaQR(String travelId, String userId) async {  
    await db.collection('travelplans').doc(travelId).update({  
      'sharedWith': FieldValue.arrayUnion([userId]),  
    });  
  }  

  Stream<List<TravelPlans>> getSharedTravelPlansStream(String userId) {  
    return db  
      .collection('travelplans')  
      .where('sharedWith', arrayContains: userId)  
      .snapshots()  
      .map((snapshot) => snapshot.docs  
        .map((doc) => TravelPlans.fromJson(doc.data()))  
        .toList());  
  }  

  Future<String> editReminder({  
    required String travelId,  
    required int daysBefore,  
  }) async {  
    try {  
      await db.collection('travelplans').doc(travelId).update({'reminderDaysBefore': daysBefore});  
      return "Successfully edited reminder!";  
    } on FirebaseException catch (e) {  
      return 'Error: ${e.message}';  
    }  
  }  

  Future<List<Map<String, dynamic>>> getSharedUsersDetails(List<String> sharedWith) async {  
    List<Map<String, dynamic>> users = [];  
    for (String userId in sharedWith) {  
      final userDoc = await db.collection('Users').doc(userId).get();  
      if (userDoc.exists) {  
        users.add({  
          'userId': userId,  
          'username': userDoc.data()?['userName'] ?? 'Unknown User',  
        });  
      }  
    }  
    return users;  
  }  
}  

