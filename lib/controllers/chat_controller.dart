import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/noti_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatController extends GetxController {
  ChatController(this.client);
  StreamChatClient client;

  static ChatController get to => Get.find();
  final UserController userCon = Get.find();
  late String gsUserID;

  /// connectChatUser
  Future<void> connectChatUser(String userID, String userName, String userImage) async {
    // 중복 커넥트 방지
    if (client.state.currentUser?.id == null) {
      await client.connectUser(
          User(
            id: userID,
            extraData: {
              'name': userName,
              'image': userImage,
            },
          ),
          client.devToken(userID).rawValue);
      Get.put(NotiController()); // noti init

      final String fcm = await FirebaseMessaging.instance.getToken() ?? 'no_fcm';
      await client.addDevice(fcm, PushProvider.firebase);
      gsUserID = client.state.currentUser?.id ?? 'no_userID';
      print('⚪ gsUserID : ${gsUserID}');

      client.on(EventType.messageNew, EventType.notificationMessageNew).listen((event) async {
        print('⚪ client.on event listen  : ${event.message?.text}');
        print('⚪ event.message?.user?.id : ${event.message?.user?.id}'); // 메세지 센더
        print('⚪ gsUserID : ${gsUserID}'); // 본인

        if (event.message?.user?.id == gsUserID) {
          /// 본인이 '#'로 특수 메세지를 보낼 때 저장
          String sendMsg = event.message?.text ?? '';
          print('⚪ sendMsg : ${sendMsg}');

          if (sendMsg.contains('#')) {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('uploadSpMessage');
            final HttpsCallableResult result = await callable({'message': sendMsg});
            debugPrint('⚪ spMsgUpload result : ${result.data}');
          }
        } else {
          NotiController.to.showLocalNoti(event);
        }
      });
    }
  }

  /// make chat room - 한번 채팅방을 hard delete 하면 권한조정이 필요하다
  Future<Channel> createChatChannel(List<String> toChatUserIDs) async {
    final core = StreamChatCore.of(Get.context!);

    toChatUserIDs.add(core.currentUser!.id); // 주최자 포함시킴

    final channel = core.client.channel('messaging', extraData: {
      'members': toChatUserIDs,
    });

    await channel.watch(); // 없으면 생성
    return channel;
  }

  /// get all users info - 현재 유저는 제외
  Future<QueryUsersResponse> queryUsers() async {
    final client = StreamChat.of(Get.context!).client;
    final QueryUsersResponse response = await client.queryUsers(
      filter: Filter.and([
        Filter.equal('role', 'user'),
        Filter.notEqual('id', userCon.userInfo.value.userID!.replaceAll('.', '_')),
      ]),
    );
    return response;
  }

  /// chat disconnect user
  Future<void> disconnectUser() async {
    final client = StreamChat.of(Get.context!).client;
    await client.disconnectUser();
  }
}
