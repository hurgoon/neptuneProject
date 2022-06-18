import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/models/event_model.dart';
import 'package:neptune_project/models/user_model.dart';

class UserController extends GetxController {
  final db = FirebaseFirestore.instance;
  final Rx<UserModel> userInfo = UserModel().obs;
  final RxList<EventModel> myEvents = <EventModel>[].obs;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> userListener;
  late List<String> previousSharedEvents = userInfo.value.sharedEvents ?? [];

  /// 로그아웃시 유저데이터 리셋
  void resetUserInfo() {
    userInfo.value = UserModel();
    userListener.cancel(); // 리스너 해제
    myEvents.clear();
    previousSharedEvents.clear();
  }

  /// 유저 데이터 리스너
  void userDataListen() {
    userListener = db.collection('users').doc(userInfo.value.userID).snapshots().listen((event) async {
      debugPrint('⚪ LISTEN ');
      if (event.data() != null) {
        myEvents.clear();
        userInfo.value = UserModel.fromJson(event.data()!);
        await getMyEvents(userInfo.value.myEvents ?? []);
        await getSharedEvents(userInfo.value.sharedEvents ?? []);

        /// 이벤트 공유 받았을 시 alert
        if (!const ListEquality().equals(previousSharedEvents, userInfo.value.sharedEvents)) {
          List<String>? diff =
              userInfo.value.sharedEvents?.toSet().difference(previousSharedEvents.toSet()).toList(); // 직전 리스트와의 차이

          if (diff?.isNotEmpty ?? false) {
            EventModel newEvent = myEvents.singleWhere((element) => element.eventID == diff?.first); // 추가된 이벤트

            Get.defaultDialog(
              titlePadding: const EdgeInsets.all(8),
              title: 'The event shared by ${newEvent.registrant}',
              content: Text('${newEvent.schedule?.month}/${newEvent.schedule?.day} : ${newEvent.contents}'),
              textConfirm: 'OK',
              confirmTextColor: Colors.white,
              onConfirm: () => Get.back(),
            );
          }

          previousSharedEvents = userInfo.value.sharedEvents ?? [];
        }
      } else {
        debugPrint('⚠️ user data is null');
      }
    });
  }

  /// 내 이벤트 파싱
  Future<void> getMyEvents(List<String> eventsID) async {
    for (String id in eventsID) {
      DocumentSnapshot<Map<String, dynamic>> eventSnap = await db.collection('events').doc(id).get();
      myEvents.add(EventModel.fromFirestore(snapshot: eventSnap));
    }
    update();
  }

  /// shared 이벤트 파싱
  Future<void> getSharedEvents(List<String> eventsID) async {
    for (String id in eventsID) {
      DocumentSnapshot<Map<String, dynamic>> eventSnap = await db.collection('events').doc(id).get();
      myEvents.add(EventModel.fromFirestore(snapshot: eventSnap, isMine: false));
    }
    update();
  }
}
