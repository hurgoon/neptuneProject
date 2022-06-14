import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController idCon = TextEditingController();
  final TextEditingController passCon = TextEditingController();
  final RxBool passVisible = RxBool(false);

  @override
  Widget build(BuildContext context) {
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
                // Obx(
                //       () => InkWell(
                //     onTap: () async {
                //       if (emailTxt.value.isEmail && validatePw()) {
                //         /// 로그인 api 콜
                //         final Map<String, dynamic> response = await apiSer.postApi(
                //           '/login',
                //           params: {
                //             "email": emailTxt.value,
                //             "password": pwTxt.value,
                //           },
                //         ) as Map<String, dynamic>;
                //
                //         if (response['status'] == 200) {
                //           /// 유저정보 저장 & 가입완료 페이지 이동
                //           final UserModel user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
                //           userCon.user.value = user;
                //           userCon.saveUserToBox();
                //           rsCon.getRsData();
                //           homeCon.tutorCheckGoingHome(); // 튜토리얼 확인하고 home page 연결
                //         } else if (response['status'] == 403) {
                //           /// 이메일 패스워드 에러시 얼럿
                //           final String errMessage = response['message'];
                //           Widgets.kCupertinoDialog(
                //             titleTxt: '로그인 실패',
                //             contentTxt: errMessage,
                //             btn1Txt: '확인',
                //             btn1Func: () {
                //               passCon.clear();
                //               Get.back();
                //             },
                //           );
                //         }
                //       }
                //     },
                //     child: Container(
                //       width: Get.width,
                //       height: 45,
                //       alignment: Alignment.center,
                //       decoration: BoxDecoration(
                //         color: (emailTxt.value.isEmail && validatePw()) ? kActivateBtn : kDeactivateBtn,
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       child: const Text(
                //         '로그인',
                //         style: TextStyle(color: Colors.white, fontSize: 14),
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
