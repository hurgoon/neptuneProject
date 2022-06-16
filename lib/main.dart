import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:neptune_project/pages/home_page.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:neptune_project/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
      ],
      home: HomePage(),
      // LoginPage(),
    );
  }
}
