import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/pages/calendar_page.dart';
import 'package:neptune_project/pages/channel_list_page.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final RxInt naviIndex = 0.obs;
  final List<Widget> tabs = [const ChannelListPage(), CalendarPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => tabs[naviIndex.value]),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            onTap: (index) {
              if (kDebugMode) print('⚪ tab index : $index');
              naviIndex.value = index;
            },
            currentIndex: naviIndex.value,
            selectedItemColor: Colors.black,
            selectedFontSize: 12,
            unselectedItemColor: Colors.grey,
            unselectedFontSize: 12,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.chat),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.chat),
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.calendar_month),
                ),
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4, top: 4),
                  child: Icon(Icons.calendar_month),
                ),
                label: 'Calendar',
              ),
            ],
          )),
    );
  }
}
