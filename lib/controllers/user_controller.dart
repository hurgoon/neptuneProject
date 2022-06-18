import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:neptune_project/models/event_model.dart';
import 'package:neptune_project/models/user_model.dart';

class UserController extends GetxController {
  Rx<UserModel> userInfo = UserModel().obs;
  RxList<EventModel> myEvents = <EventModel>[].obs;
  final db = FirebaseFirestore.instance;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> userListener;

  /// 로그아웃시 유저데이터 리셋
  void resetUserInfo() {
    userInfo.value = UserModel();
    userListener.cancel(); // 리스너 해제
  }

  /// 유저 데이터 파싱 리스너 필요
  void userDataListen() {
    userListener = db.collection('users').doc(userInfo.value.userID).snapshots().listen((event) {
      print('⚪⚪⚪ LISTEN ');
      if (event.data() != null) {
        userInfo.value = UserModel.fromJson(event.data()!);
        getMyEvents(userInfo.value.myEvents ?? []);
      } else {
        debugPrint('⚠️ user data is null');
      }
    });
  }

  /// 내 이벤트 파싱
  Future<void> getMyEvents(List<String> eventsID) async {
    myEvents.clear();
    for (String id in eventsID) {
      DocumentSnapshot<Map<String, dynamic>> eventSnap = await db.collection('events').doc(id).get();
      myEvents.add(EventModel.fromFirestore(eventSnap));
    }
    update();
  }

  /// shared 이벤트 파싱
}
