import 'package:get/get.dart';
import 'package:neptune_project/models/user_model.dart';

class UserController extends GetxController{
  UserModel userInfo = UserModel();

  void resetUserInfo() => userInfo = UserModel();
}