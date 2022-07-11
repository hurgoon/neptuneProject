import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neptune_project/app.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiController extends GetxController {
  NotiController(this.client);
  StreamChatClient client;

  static NotiController get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late String fcmToken;

  @override
  void onInit() {
    super.onInit();
    setupNotifications();
  }

  Future<void> setupNotifications() async {
    final res = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (res.authorizationStatus != AuthorizationStatus.authorized) {
      throw ArgumentError('⚠️ You must allow notification permissions in order to receive push notifications');
    }

    await _messaging.getToken().then((token) {
      updateToken(token ?? 'no_token');
    });
    _messaging.onTokenRefresh.listen(updateToken);

    /// foreground state
    FirebaseMessaging.onMessage.listen((fore) {
      print('⚪ fore : ${fore.notification?.title}');
      print('⚪ body : ${fore.notification?.body}');
    });

    /// background state (백그라운드에서 노티 눌렀을 때 앱 켜지면서 발동)
    FirebaseMessaging.onMessageOpenedApp.listen((back) {
      print('⚪ back : ${back.notification?.title}');
      print('⚪ body : ${back.notification?.body}');
    });

    /// terminated state (앱킬에서 노티 눌렀을 때 앱 켜지면서 발동)
    FirebaseMessaging.instance.getInitialMessage().then((terminated) {
      if (terminated != null) {
        print('⚪ terminated : ${terminated.notification?.title}');
        print('⚪ body : ${terminated.notification?.body}');
      }
    });
  }

  void updateToken(String token) {
    client.addDevice(token, PushProvider.firebase);
    fcmToken = token;
  }
}

Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('⚪ onBackgroundMessage : ${message}');

  final client = StreamChatClient(streamKey);
  final String gsUserID = client.state.currentUser?.id ?? 'no_id';
  final String gsUserToken = client.devToken(gsUserID).rawValue;
  print('⚪ 1 gsUserID: ${gsUserID}'); // todo no_id 이슈 있음
  print('⚪ 1 gsUserToken : ${gsUserToken}');

  await client.connectUser(
    User(id: gsUserID),
    gsUserToken,
    connectWebSocket: false,
  );

  handleNotification(message, client);
}

void handleNotification(RemoteMessage message, StreamChatClient client) async {
  final data = message.data;

  if (data['type'] == 'message.new') {
    final flutterLocalNotificationsPlugin = await setupLocalNotifications();
    final messageId = data['id'];
    final response = await client.getMessage(messageId);

    flutterLocalNotificationsPlugin.show(
      1,
      '⚪ New message from ${response.message.user?.name} in ${response.channel?.name}',
      response.message.text,
      const NotificationDetails(
          android: AndroidNotificationDetails(
        'new_message',
        'New message notifications channel',
      )),
    );
  }
}

Future<FlutterLocalNotificationsPlugin> setupLocalNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  return flutterLocalNotificationsPlugin;
}
