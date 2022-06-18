class UserModel {
  UserModel({this.userID, this.myEvents, this.sharedEvents});
  String? userID;
  List<String>? myEvents;
  List<String>? sharedEvents;

  UserModel.fromJson(Map<String, dynamic> json)
      : userID = json['user_id'],
        myEvents = (json['my_events'] ?? []).cast<String>(),
        sharedEvents = (json['shared_events'] ?? []).cast<String>();
}
