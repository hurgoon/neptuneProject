import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/event_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:neptune_project/models/event_model.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final UserController userCon = Get.isRegistered<UserController>() ? Get.find() : Get.put(UserController());
  final EventController eventCon = Get.isRegistered<EventController>() ? Get.find() : Get.put(EventController());
  final Rx<CalendarFormat> _calendarFormat = CalendarFormat.month.obs;
  final Rx<DateTime> _focusedDay = DateTime.now().obs;
  late final Rx<DateTime?> _selectedDay = _focusedDay.value.obs;
  late final RxList<EventModel> _selectedEvents = _getEventsForDay(_selectedDay.value!).obs;
  final DateTime kToday = DateTime.now();
  late final DateTime kFirstDay = DateTime(kToday.year, kToday.month - 12, kToday.day);
  late final DateTime kLastDay = DateTime(kToday.year, kToday.month + 12, kToday.day);

  /// 선택일 이벤트
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay.value, selectedDay)) {
      _selectedDay.value = selectedDay;
      _focusedDay.value = focusedDay;
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  /// 일별 이벤트
  List<EventModel> _getEventsForDay(DateTime day) {
    return eventCon.events.where((event) => isSameDay(event.time, day)).toList();
  }

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
      body: Column(
        children: [
          /// 캘린더 표시
          Obx(() => TableCalendar<EventModel>(
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: _focusedDay.value,
                selectedDayPredicate: (day) => isSameDay(_selectedDay.value, day),
                calendarFormat: _calendarFormat.value,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat.value != format) _calendarFormat.value = format;
                },
                onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
              )),
          const SizedBox(height: 8.0),

          /// 이벤트 표시
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (_, index) {
                  final EventModel event = _selectedEvents[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: (event.isMine ?? true) ? Colors.black : Colors.red), // 공유된 스케쥴은 빨강
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => print('${event}'),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!(event.isMine ?? true))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Shared by ${event.sharedID}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          Text(event.title ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
