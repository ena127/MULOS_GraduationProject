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
        title: Text("MULOS", style: TextStyle(color: Colors.black),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 70,),
          const Row(children: [Expanded(child: SizedBox())],),
          UserScreenItem(onTap: () {
            Get.offNamed(AppRouter.confirm_rental, arguments: {
              "selected_devices": ["기기1","기기2"],
              "professor": "김홍익",
            });
          }, title: "대여 및 반납"),
          const SizedBox(height: 40,),
          UserScreenItem(onTap: () {

          }, title: "승인 요청 내역"),
          const SizedBox(height: 40,),
          UserScreenItem(onTap: () {
            controller.signOut();
          }, title: "로그아웃"),
        ],
      ),
    );
  }

}


class UserController extends GetxController{


  Future<void> signOut() async {
    await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, false) ?? false;
    Get.offAllNamed(AppRouter.sign_in);
  }

}
