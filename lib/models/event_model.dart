import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  const EventModel({
    this.eventID,
    this.contents,
    this.schedule,
    this.registrant,
    this.isMine,
  });

  final String? eventID;
  final String? contents;
  final DateTime? schedule;
  final String? registrant; // 등록자
  final bool? isMine; // 내 스케쥴인지 공유된 스케쥴인지 구분

  Map<String, dynamic> toFirestore() {
    return {
      if (eventID != null) "event_id": eventID,
      if (schedule != null) "schedule": schedule,
      if (registrant != null) "registrant": registrant,
      if (contents != null) "contents": contents,
    };
  }

  factory EventModel.fromFirestore({required DocumentSnapshot<Map<String, dynamic>> snapshot, bool isMine = true}) {
    final data = snapshot.data();
    return EventModel(
      eventID: data?['event_id'],
      schedule: data?['schedule'].toDate(),
      registrant: data?['registrant'],
      contents: data?['contents'],
      isMine: isMine,
    );
  }

  @override
  String toString() => contents ?? 'no_title';
}
