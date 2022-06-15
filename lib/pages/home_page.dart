import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final UserController userCon = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              userCon.resetUserInfo(); // 유저정보 리셋
              Get.offNamed('/login'); // 로그인페이지 이동
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
            ),
          ],
        ),
      ),
    );
  }
}
