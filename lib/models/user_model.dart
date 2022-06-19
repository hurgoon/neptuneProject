class UserModel {
  UserModel({this.userID, this.myEvents, this.sharedEvents});
  String? userID;
  List<String>? myEvents; // 내가 등록한 이벤트
  List<String>? sharedEvents; // 쉐어 받은 이벤트

  UserModel.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'],
        myEvents = (json['my_events'] ?? []).cast<String>(),
        sharedEvents = (json['shared_events'] ?? []).cast<String>();
}
