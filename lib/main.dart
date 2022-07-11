import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:neptune_project/app.dart';
import 'package:neptune_project/controllers/chat_controller.dart';
import 'package:neptune_project/controllers/noti_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:neptune_project/firebase_options.dart';
import 'package:neptune_project/pages/calendar_page.dart';
import 'package:neptune_project/pages/home_page.dart';
import 'package:neptune_project/pages/login_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // fb init
  FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final auth = fb.FirebaseAuth.instance;
    final client = StreamChatClient(
      streamKey,
      //    logLevel: Level.INFO
    );

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/calendar', page: () => CalendarPage()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(UserController());
        Get.put(ChatController());
      }),
      initialRoute: auth.currentUser == null ? '/login' : '/home',
      builder: (_, child) {
        return StreamChat(
          client: client,
          child: child,
          backgroundKeepAlive: const Duration(minutes: 30),
          onBackgroundEventReceived: (event) async {
            final currentUserId = client.state.currentUser?.id;
            if (![
                  EventType.messageNew,
                  EventType.notificationMessageNew,
                ].contains(event.type) ||
                event.user?.id == currentUserId) {
              return;
            }
            if (event.message == null) return;
            final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
            const initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
            const initializationSettingsIOS = IOSInitializationSettings();
            const initializationSettings = InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: initializationSettingsIOS,
            );
            await flutterLocalNotificationsPlugin.initialize(initializationSettings);
            await flutterLocalNotificationsPlugin.show(
              event.message?.id.hashCode ?? 0,
              event.message?.user?.name,
              event.message?.text,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'message channel',
                  'Message channel',
                  channelDescription: 'Channel used for showing messages',
                  priority: Priority.high,
                  importance: Importance.high,
                ),
                iOS: IOSNotificationDetails(),
              ),
            );
          },
        );
      },
    );
  }
}
