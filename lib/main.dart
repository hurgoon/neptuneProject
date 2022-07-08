import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:neptune_project/app.dart';
import 'package:neptune_project/controllers/chat_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:neptune_project/firebase_options.dart';
import 'package:neptune_project/pages/calendar_page.dart';
import 'package:neptune_project/pages/home_page.dart';
import 'package:neptune_project/pages/login_page.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // fb init
  final client = StreamChatClient(streamKey, logLevel: Level.INFO); // getStream setup

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.client}) : super(key: key);
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
        Get.put(ChatController());
      }),
      initialRoute: auth.currentUser == null ? '/login' : '/home',
      builder: (_, child) {
        return StreamChat(client: client, child: child);
      },
    );
  }
}
