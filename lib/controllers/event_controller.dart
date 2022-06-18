import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/user_controller.dart';

class EventController extends GetxController {
  final UserController userCon = Get.find();
  final db = FirebaseFirestore.instance;

  /// 이벤트 add -> 저장한 ID 리턴
  Future<String> eventAdd(Map<String, dynamic> savingEvent) async {
    String docID = db.collection('events').doc().id;
    savingEvent['event_id'] = docID;
    await db.collection('events').doc(docID).set(savingEvent);
    return docID;
  }

  /// my_events 업데이트
  Future<void> updateMyEvents(String eventID) async {
    userCon.userInfo.value.myEvents ??= [];
    userCon.userInfo.value.myEvents?.add(eventID); // 이벤트 ID 추가
    await db
        .collection('users')
        .doc(userCon.userInfo.value.userID)
        .update({'my_events': userCon.userInfo.value.myEvents});
  }

  /// shared_events 업데이트
  Future<void> updateSharedEvents(String shareUser, String eventID) async {
    final DocumentSnapshot<Map<String, dynamic>> userSnap = await db.collection('users').doc(shareUser).get();
    List<String> sharedEvents = (userSnap.data()?['shared_events'] ?? []).cast<String>();
    sharedEvents.add(eventID);
    await db.collection('users').doc(shareUser).update({'shared_events': sharedEvents});
  }

  /// 쉐어할 수 있는 유저를 리턴
  Future<List<String>> getShareUsers() async {
    final QuerySnapshot<Map<String, dynamic>> userCollection = await db.collection('users').get();
    List<String> tempList = userCollection.docs.map((e) => e.id).toList();
    tempList.removeWhere((e) => e == userCon.userInfo.value.userID); // 자기 ID는 제외
    return tempList;
  }
}

// /// Returns `date` in UTC format, without its time part.
// DateTime normalizeDate(DateTime date) {
//   return DateTime.utc(date.year, date.month, date.day);
// }
//
// /// Checks if two DateTime objects are the same day.
// /// Returns `false` if either of them is null.
// bool isSameDay(DateTime? a, DateTime? b) {
//   if (a == null || b == null) {
//     return false;
//   }
//
//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }
