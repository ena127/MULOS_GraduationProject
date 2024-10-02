import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_router.dart';

import '../../constants/app_colors.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(SignUpController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text("정규학기 대여", style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
            const SizedBox(height: 20,),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              controller: controller.idTextController,
              decoration: InputDecoration(
                hintText: "학번",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 13,),
            TextField(
              obscureText: true,
              controller: controller.passwordTextController,
              decoration: InputDecoration(
                hintText: "비밀번호",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40,),
            Text("회원가입 후 최초 1회는 클래스넷 인증이 필요합니다."),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: () {
              controller.signUp();
            }, child: Text("클래스넷 이미지 등록하고 정보 연동하기"))
          ],
        ),
      ),
    );
  }

}


class SignUpController extends GetxController{

  late TextEditingController idTextController;
  late TextEditingController passwordTextController;


  @override
  void onInit() {
    idTextController = TextEditingController();
    passwordTextController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    idTextController.dispose();
    passwordTextController.dispose();
    super.onClose();
  }



  void signUp() async {
    var id = idTextController.value.text;
    var password = passwordTextController.value.text;

    Get.toNamed(AppRouter.academic_record);

  }

}
