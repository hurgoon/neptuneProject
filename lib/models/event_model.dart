class EventModel {
  const EventModel({this.title, this.time, this.isMine, this.sharedID});

  final String? title;
  final DateTime? time;
  final bool? isMine; // 내 스케쥴인지 공유된 스케쥴인지 구분
  final String? sharedID; // 스케쥴 공유해준 ID

  @override
  String toString() => title ?? 'no_title';
}
