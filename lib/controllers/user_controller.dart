import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neptune_project/controllers/chat_controller.dart';
import 'package:neptune_project/models/event_model.dart';
import 'package:neptune_project/models/user_model.dart';

class UserController extends GetxController {
  final db = FirebaseFirestore.instance;
  final Rx<UserModel> userInfo = UserModel().obs;
  final RxList<EventModel> myEvents = <EventModel>[].obs; // myEvent + sharedEvent 데이터
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> userListener; // 리스너 해제용
  late List<String> previousSharedEvents = userInfo.value.sharedEvents ?? []; // 공유된 스케쥴 비교용

  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void onInit() {
    super.onInit();

    /// google auto login case
    if (userInfo.value.userID == null && auth.currentUser != null) {
      userInfo.value.userID = auth.currentUser?.email ?? 'no_email';
      userDataListen();
    }
  }

  /// 로그아웃시 유저데이터 리셋
  Future<void> resetUserInfo() async {
    await handleSignOut();
    userInfo.value = UserModel();
    userListener.cancel(); // 리스너 해제
    myEvents.clear();
    previousSharedEvents.clear();
  }

  /// 유저 데이터 리스너
  void userDataListen() async {
    userListener = db.collection('users').doc(userInfo.value.userID).snapshots().listen((event) async {
      debugPrint('⚪ LISTEN : ${userInfo.value.userID}');
      if (event.data() != null) {
        myEvents.clear();
        userInfo.value = UserModel.fromJson(event.data()!);
        await getMyEvents(userInfo.value.myEvents ?? []);
        await getSharedEvents(userInfo.value.sharedEvents ?? []);
        await ChatController.to.connectChatUser(userInfo.value.userID ?? 'no_userID',
            userInfo.value.userName ?? 'no_userName', userInfo.value.userImage ?? 'no_userImage');

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

  /// google login
  Future<void> handleSignIn() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredentialData = await FirebaseAuth.instance.signInWithCredential(credential);
      final String userEmail = userCredentialData.user?.email.toString() ?? 'no_email'; // google login email
      final String? userImage = userCredentialData.user?.photoURL;
      final String? userName = userCredentialData.user?.displayName;

      final userRef = db.collection('users').doc(userEmail);
      userRef.get().then((docSnapshot) async {
        if (docSnapshot.exists) {
          /// user is registered
          UserModel user = UserModel.fromJson(docSnapshot.data() ?? {});
          userInfo.value = user;
        } else {
          /// user is not registered
          await userRef.set({
            'user_id': userEmail,
            'user_image': userImage,
            'user_name': userName,
          }); // save user to firestore
          userInfo.value = UserModel(userID: userEmail, userImage: userImage, userName: userName);
          // await createChatUser(userEmail, userName ?? 'no_name', userImage ?? 'no_image');
        }
        previousSharedEvents = userInfo.value.sharedEvents ?? [];
        userDataListen();
        Get.offNamed('/home'); // 로그인 화면으로
      });
    } catch (error) {
      if (kDebugMode) print(error);
    }
  }

  /// google & getStream logout
  Future<void> handleSignOut() async {
    await auth.signOut();
    await googleSignIn.disconnect();
    await ChatController.to.disconnectUser(); // chat disconnect
  }
}
