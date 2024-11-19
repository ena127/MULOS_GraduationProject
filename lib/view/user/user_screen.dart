import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_router.dart';
import 'package:mulos/view/user/user_screen_item.dart';

import '../../constants/app_prefs_keys.dart';
import '../../service/preference_service.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 70),
          const Row(children: [Expanded(child: SizedBox())]),

          // 대여 및 반납 버튼
          UserScreenItem(
            onTap: () {
              Get.offNamed(AppRouter.confirm_rental, arguments: {
                "selected_devices": ["기기1", "기기2"],
                "professor": "김홍익",
              });
            },
            title: "대여 및 반납",
          ),
          const SizedBox(height: 40),

          // 승인 요청 내역 버튼
          UserScreenItem(
            onTap: () {},
            title: "승인 요청 내역",
          ),
          const SizedBox(height: 40),

          // 로그아웃 버튼
          UserScreenItem(
            onTap: () {
              controller.signOut();
            },
            title: "로그아웃",
          ),
          const SizedBox(height: 50),

          // 사용자 정보 표시
          Obx(() {
            return Column(
              children: [
                const SizedBox(height: 20),
                Text("학번: ${controller.studentId.value}", style: const TextStyle(fontSize: 18)),
                Text("이름: ${controller.name.value}", style: const TextStyle(fontSize: 18)),
                Text("이메일: ${controller.email.value}", style: const TextStyle(fontSize: 18)),
                Text("교수님: ${controller.professor.value}", style: const TextStyle(fontSize: 18)),
              ],
            );
          })
        ],
      ),
    );
  }
}

class UserController extends GetxController {
  RxString studentId = ''.obs;
  RxString name = ''.obs;
  RxString email = ''.obs;
  RxString photoUrl = ''.obs;
  RxString professor = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  void loadUserInfo() {
    studentId.value = AppPreferences().prefs?.getString('studentId') ?? '';
    name.value = AppPreferences().prefs?.getString('name') ?? '';
    email.value = AppPreferences().prefs?.getString('email') ?? '';
    photoUrl.value = AppPreferences().prefs?.getString('photoUrl') ?? '';
    professor.value = AppPreferences().prefs?.getString('professor') ?? '';
    update(); // 사용자 정보를 불러온 후 UI 업데이트
  }


  Future<void> signOut() async {
  await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, false);
  Get.offAllNamed(AppRouter.sign_in);
  }
}
