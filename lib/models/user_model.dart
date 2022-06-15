class UserModel {
  UserModel({this.userID});
  String? userID;

  UserModel.fromJson(Map<String, dynamic> json) : userID = json['user_id'];
}
