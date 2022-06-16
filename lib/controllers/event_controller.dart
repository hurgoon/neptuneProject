import 'package:get/get.dart';
import 'package:neptune_project/models/event_model.dart';

class EventController extends GetxController {
  List<EventModel> events = [
    EventModel(title: '111', time: DateTime.now(), isMine: true),
    EventModel(title: '222', time: DateTime.now().add(Duration(days: 1)), isMine: true),
    EventModel(title: '333', time: DateTime.now().subtract(Duration(days: 1)), isMine: true),
    EventModel(title: '444', time: DateTime.now().subtract(Duration(days: 1)), isMine: false, sharedID: 'Tony'),
  ];

  /// 스케쥴 파싱 (리스너 대응 필요)

  /// 스케쥴 add
}

// /// Returns `date` in UTC format, without its time part.
// DateTime normalizeDate(DateTime date) {
//   return DateTime.utc(date.year, date.month, date.day);
// }
//
// /// Checks if two DateTime objects are the same day.
// /// Returns `false` if either of them is null.
// bool isSameDay(DateTime? a, DateTime? b) {
//   if (a == null || b == null) {
//     return false;
//   }
//
//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }
