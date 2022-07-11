import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/noti_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.find();
  final UserController userCon = Get.find();

  /// connectChatUser
  Future<void> connectChatUser(String userID, String userName, String userImage) async {
    final StreamChatClient client = StreamChat.of(Get.context!).client;

    // 중복 커넥트 방지
    if (client.state.currentUser?.id == null) {
      await client.connectUser(
          User(
            id: userID.replaceAll('.', '_'),
            extraData: {
              'name': userName,
              'image': userImage,
            },
          ),
          client.devToken(userID.replaceAll('.', '_')).rawValue);
      Get.put(NotiController(client)); // noti init

      final String fcm = await FirebaseMessaging.instance.getToken() ?? 'no_fcm';
      await client.addDevice(fcm, PushProvider.firebase);
      final currentUserID = client.state.currentUser?.id ?? 'no_userID';
      client.on(EventType.messageNew, EventType.notificationMessageNew).listen((event) async {
        print('⚪ client.on event listen  : ${event.message}');

        if (event.message?.user?.id == currentUserID) {
          return;
        }
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        const initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
        const initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
        );
        await flutterLocalNotificationsPlugin.initialize(initializationSettings);
        await flutterLocalNotificationsPlugin.show(
          event.message?.id.hashCode ?? 0,
          'New message from : ' + (event.message?.user?.name ?? 'no_name'),
          event.message?.text,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'message channel',
              'Message channel',
              channelDescription: 'Channel used for showing messages',
              // icon: '@drawable/notification',
              priority: Priority.high,
              importance: Importance.high,
            ),
          ),
        );
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
