import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  const EventModel({
    this.eventID,
    this.contents,
    this.schedule,
    this.registrant,
    this.isMine,
    this.sharedID,
  });

  final String? eventID;
  final String? contents;
  final DateTime? schedule;
  final String? registrant; // 등록자

  final bool? isMine; // todo del 내 스케쥴인지 공유된 스케쥴인지 구분
  final String? sharedID; // todo del 스케쥴 공유해준 ID

  Map<String, dynamic> toFirestore() {
    return {
      if (eventID != null) "event_id": eventID,
      if (schedule != null) "schedule": schedule,
      if (registrant != null) "registrant": registrant,
      if (contents != null) "contents": contents,
    };
  }

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return EventModel(
      eventID: data?['event_id'],
      schedule: data?['schedule'].toDate(),
      registrant: data?['registrant'],
      contents: data?['contents'],
    );
  }

  @override
  String toString() => contents ?? 'no_title';
}
