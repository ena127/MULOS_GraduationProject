import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';

import '../../constants/app_prefs_keys.dart';
import '../../service/preference_service.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(SignInController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/image/app_icon.png"),
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
            const SizedBox(height: 13,),
            ElevatedButton(onPressed: () {
              controller.verifyLogin();
            }, child: Text("로그인")),
            const SizedBox(height: 20,),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xffFFEB00),
                borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset("assets/image/ic_logo_kakao.svg"),
                  Text("카카오로 시작하기"),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: false,
                    child: SvgPicture.asset("assets/image/ic_logo_kakao.svg")
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13,),
            Container(
              decoration: const BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset("assets/image/ic_logo_google.svg"),
                  Text("구글로 시작하기"),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: false,
                    child: SvgPicture.asset("assets/image/ic_logo_google.svg")
                  ),
                ],
              ),
            ),
            TextButton(onPressed: () {
              Get.toNamed(AppRouter.sign_up);
            }, child: Text("회원가입", style: TextStyle(color: Colors.black),)),
            TextButton(onPressed: () {
              Get.toNamed(AppRouter.admin);
            }, child: Text("관리자", style: TextStyle(color: Colors.black)))
          ],
        ),
      ),
    );
  }

}


class SignInController extends GetxController{

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



  void verifyLogin() async {
    var id = idTextController.value.text;
    var password = passwordTextController.value.text;

    if(id == "12345678" && password == "12345678"){
      await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true) ?? false;
      Get.offNamed(AppRouter.home);
      return;
    }

    Fluttertoast.showToast(msg: "학번 혹은 비밀번호가 일치하지 않습니다.");

  }

}