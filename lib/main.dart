import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final StreamChatClient client = StreamChatClient(
    streamKey,
    //    logLevel: Level.INFO
  );

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.client, Key? key}) : super(key: key);
  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final auth = fb.FirebaseAuth.instance;

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
        Get.put(ChatController(client));
      }),
      initialRoute: auth.currentUser == null ? '/login' : '/home',
      builder: (context, child) {
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
            NotiController.to.showLocalNoti(event);
          },
        );
      },
    );
  }
}
