import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/event_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:neptune_project/models/event_model.dart';
import 'package:group_button/group_button.dart';

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
  final TextEditingController contentsCon = TextEditingController();
  final GroupButtonController shareCon = GroupButtonController();

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
    return userCon.myEvents.where((event) => isSameDay(event.schedule, day)).toList();
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
          GetBuilder(
              init: userCon,
              builder: (_) {
                return Obx(() => TableCalendar<EventModel>(
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
                    ));
              }),
          const SizedBox(height: 8.0),

          /// 이벤트 표시
          Expanded(
            child: Obx(() {
              _selectedEvents.value = _getEventsForDay(_selectedDay.value!);
              return ListView.builder(
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
                          Text(event.contents ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<String> userList = []; // 공유할 유저 리스트
          contentsCon.clear(); // 이벤트 콘텐츠 리셋
          shareCon.unselectAll(); // 쉐어유저 버튼 리셋

          Get.defaultDialog(
              title: 'Add Event\nDate : ${_selectedDay.value?.month}/${_selectedDay.value?.day}',
              titleStyle: const TextStyle(fontSize: 15),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: contentsCon,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요.',
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                        isDense: true,
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                        errorStyle: const TextStyle(fontSize: 10, color: Colors.red),
                        suffixIcon: (contentsCon.text.isNotEmpty)
                            ? InkWell(
                                onTap: () => contentsCon.clear(),
                                child: const Icon(Icons.close),
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(maxHeight: 24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Share event with',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                      future: eventCon.getShareUsers(),
                      builder: (_, snapshot) {
                        if (!snapshot.hasData) return const CupertinoActivityIndicator();
                        userList = snapshot.data as List<String>;
                        return GroupButton(
                          controller: shareCon,
                          buttons: userList,
                          isRadio: false,
                          options: GroupButtonOptions(
                            borderRadius: BorderRadius.circular(10),
                            unselectedColor: Colors.grey,
                            selectedColor: Colors.black,
                            unselectedTextStyle: const TextStyle(color: Colors.white),
                            selectedTextStyle: const TextStyle(color: Colors.white),
                          ),
                          onSelected: (txt, i, selected) => debugPrint('Button $txt #$i $selected'),
                        );
                      }),
                ],
              ),
              onCancel: () => Get.back(),
              confirmTextColor: Colors.white,
              onConfirm: () async {
                Get.dialog(const CupertinoActivityIndicator()); // 인디케이터 발동

                Map<String, dynamic> savingEvent = EventModel(
                  schedule: _selectedDay.value,
                  registrant: userCon.userInfo.value.userID,
                  contents: contentsCon.text,
                ).toFirestore();

                /// event 컬렉션 add
                final String eventID = await eventCon.eventAdd(savingEvent);

                /// 유저 'myEvent' ID add
                await eventCon.updateMyEvents(eventID);

                /// 쉐어 'sharedEvent' ID add
                List<String> shareUsers = [];
                for (int index in shareCon.selectedIndexes) {
                  shareUsers.add(userList[index]); // 선택된 유저 추출
                }
                for (String userID in shareUsers) {
                  eventCon.updateSharedEvents(userID, eventID); // 업데이트
                }

                Get.back(); // 인디케이터 해제
                Get.back(); // 다이얼로그 해제
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
