import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constants/app_prefs_keys.dart';
import '../../service/preference_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(HomeController());
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: Column(
        children: [
          Image.asset("assets/image/app_icon.png", width: shortestSide * 0.8, height: shortestSide * 0.8,),
          Obx(() {
            return ElevatedButton(onPressed: () {
              if(controller.qrData.value < 0){
                controller.startTimer();
                return;
              }
            }, child: Text("${controller.qrData.value < 0 ? "라운지 입장" : "${controller.remainingSeconds.value} sec ..."}"));
          },),
          const SizedBox(height: 20,),
          Expanded(
            child: Obx(() {
              if(controller.qrData.value < 0){
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Column(
                        children: [
                          Text("좌석 현황"),

                          Obx(() => Text("모니터석 : ${controller.monitorCount.value}/${controller.monitorTotalCount.value}"),),
                          Obx(() => Text("데스크탑 : ${controller.desktopCount.value}/${controller.desktopTotalCount.value}"),),
                          Obx(() => Text("그룹학습 : ${controller.groupStudyCount.value}/${controller.groupStudyTotalCount.value}"),),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Obx(() {

                      var total = controller.monitorTotalCount.value + controller.desktopTotalCount.value + controller.groupStudyTotalCount.value;
                      var count = controller.monitorCount.value + controller.desktopCount.value + controller.groupStudyCount.value;
                      var percent = count / total;

                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: percent <= 0.333 ? Colors.green : percent >= 0.666 ? Colors.red : Colors.yellow
                        ),
                        child: Text(percent <= 0.333 ? "원활" : percent >= 0.666 ? "혼잡" : "보통", style: const TextStyle(color: Colors.white),),
                      );
                    },),
                  ],
                );
              }else {
                return Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return QrImageView(
                          data: '${controller.qrData.value}',
                          version: QrVersions.auto,
                          size: 270.0,
                        );
                      },),
                    ),
                    const SizedBox(height: 20,),
                    GestureDetector(
                      onTap: () {
                        controller.startTimer();
                      },
                      child: const Column(
                        children: [
                          Icon(Icons.refresh, color: AppColors.main,),
                          Text("Regenerate")
                        ],
                      ),
                    )
                  ],
                );
              }
            },),
          ),
          const SizedBox(height: 80,),

          Container(
            padding: EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.grey200,
                      offset: Offset(0, -5),
                      blurRadius: 20
                  )
                ]
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SafeArea(
                  top:false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRouter.menu);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.desktop_mac_outlined, size: 40,),
                            Text("RENTAL")
                          ],
                        ),
                      ),
                      SizedBox(),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRouter.user);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sentiment_satisfied, size: 40),
                            Text("MY")
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: GestureDetector(
                    onTap: () {
                      controller.stopTimer();
                    },
                    child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: AppColors.main,
                            shape: BoxShape.circle
                        ),
                        child: Icon(Icons.home_outlined, size: 30, color: Colors.white,)
                    ),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }

}


class HomeController extends GetxController{

  var qrData = (-1).obs;
  RxInt remainingSeconds = 30.obs;
  Timer? timer;
  RxInt monitorCount = 0.obs;
  RxInt desktopCount = 0.obs;
  RxInt groupStudyCount = 0.obs;
  RxInt monitorTotalCount = 0.obs;
  RxInt desktopTotalCount = 0.obs;
  RxInt groupStudyTotalCount = 0.obs;



  @override
  void onInit() {
    monitorCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.monitorCount) ?? 0;
    desktopCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.desktopCount) ?? 0;
    groupStudyCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.groupStudyCount) ?? 0;
    monitorTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.monitorTotalCount) ?? 0;
    desktopTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.desktopTotalCount) ?? 0;
    groupStudyTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.groupStudyTotalCount) ?? 0;
    super.onInit();
  }

  void startTimer() {
    refreshQr();
    timer?.cancel();
    timer = null;
    remainingSeconds.value = 30;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        refreshQr();
        remainingSeconds.value = 30; // 30초 초기화
      }
    });
  }

  void stopTimer(){
    timer?.cancel();
    timer = null;
    qrData.value = -1;
  }

  void refreshQr(){
    qrData.value = Random().nextInt(10000);
  }

  @override
  void onClose() {
    timer?.cancel(); // 컨트롤러가 종료될 때 타이머 취소
    super.onClose();
  }


}
