import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neptune_project/controllers/event_controller.dart';
import 'package:neptune_project/controllers/user_controller.dart';
import 'package:neptune_project/models/user_model.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final UserController userCon = Get.put(UserController());
  final EventController eventCon = Get.put(EventController());

  final TextEditingController idCon = TextEditingController();
  final TextEditingController passCon = TextEditingController();
  final RxBool passVisible = RxBool(false);
  final RxString idTxt = ''.obs;
  final RxString passTxt = ''.obs;
  final db = FirebaseFirestore.instance;

  /// 입력한 ID가 존재하는지 확인
  Future<bool> checkIdExists(String id) async {
    final CollectionReference<Map<String, dynamic>> collectionRef = db.collection('users');
    var doc = await collectionRef.doc(id).get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    idCon.addListener(() => idTxt.value = idCon.text);
    passCon.addListener(() => passTxt.value = passCon.text);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 이메일 섹션
                const Text('ID', style: TextStyle(fontSize: 22, color: Colors.black)),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: TextFormField(
                    controller: idCon,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'ID를 입력해주세요.',
                      hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                      isDense: true,
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                      errorStyle: const TextStyle(fontSize: 10, color: Colors.red),
                      suffixIcon: (idCon.text.isNotEmpty)
                          ? InkWell(
                              onTap: () => idCon.clear(),
                              child: const Icon(Icons.close),
                            )
                          : null,
                      suffixIconConstraints: const BoxConstraints(maxHeight: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 37),

                /// 비밀번호 섹션
                const Text('Password', style: TextStyle(fontSize: 22, color: Colors.black)),
                const SizedBox(height: 3),
                Obx(() => Form(
                      autovalidateMode: AutovalidateMode.always,
                      child: TextFormField(
                        controller: passCon,
                        obscureText: !passVisible.value,
                        decoration: InputDecoration(
                          hintText: 'Password를 입력해주세요.',
                          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                          isDense: true,
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                          focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                          errorStyle: const TextStyle(fontSize: 10, color: Colors.red),
                          suffixIconConstraints: const BoxConstraints(maxHeight: 14),
                          suffixIcon: IconButton(
                            onPressed: () {
                              passVisible.value = !passVisible.value;
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              passVisible.value ? Icons.remove_red_eye_outlined : Icons.visibility_off_outlined,
                              size: 24,
                              color: passVisible.value ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 40),

                /// 로그인 버튼
                Obx(
                  () => InkWell(
                    onTap: () async {
                      if (idTxt.value.isNotEmpty && passTxt.value.isNotEmpty) {
                        /// 인디케이터 발동
                        Get.dialog(const CupertinoActivityIndicator());

                        /// ID check
                        if (!await checkIdExists(idTxt.value)) {
                          if (Get.isDialogOpen ?? false) Get.back(); // indicator off
                          Get.defaultDialog(
                            content: const Text('존재하지 않는 ID입니다.'),
                            textConfirm: 'OK',
                            confirmTextColor: Colors.white,
                            onConfirm: () => Get.back(),
                          );
                        } else {
                          final DocumentSnapshot<Map<String, dynamic>> userDoc =
                              await db.collection('users').doc(idTxt.value).get();
                          if (Get.isDialogOpen ?? false) Get.back(); // indicator off

                          /// Password check
                          if (userDoc['password'] != passTxt.value) {
                            Get.defaultDialog(
                              content: const Text('Password가 일치하지 않습니다.'),
                              textConfirm: 'OK',
                              confirmTextColor: Colors.white,
                              onConfirm: () => Get.back(),
                            );
                          } else {
                            UserModel user = UserModel.fromJson(userDoc.data() ?? {});
                            userCon.userInfo.value = user; // 유저정보 저장
                            userCon.previousSharedEvents = userCon.userInfo.value.sharedEvents ?? [];
                            userCon.userDataListen();
                            Get.offNamed('/home'); // 로그인 화면으로
                          }
                        }
                      } else {
                        Get.defaultDialog(
                          content: const Text('ID와 Password를 입력해주세요.'),
                          textConfirm: 'OK',
                          confirmTextColor: Colors.white,
                          onConfirm: () => Get.back(),
                        );
                      }
                    },
                    child: Container(
                      width: Get.width,
                      height: 45,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (idTxt.value.isNotEmpty && passTxt.value.isNotEmpty) ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Divider(color: Colors.black, thickness: 3),
                ),

                /// google login btn
                InkWell(
                    onTap: () {
                      Get.dialog(const CupertinoActivityIndicator(color: Colors.white)); // 인디케이터 발동
                      userCon.handleSignIn().then((value) => Get.back());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Image.network('https://firebase.flutter.dev/img/flutterfire_300x.png', width: 80),
                          const SizedBox(width: 20),
                          const Text('GOOGLE SIGN IN'),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
