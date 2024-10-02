import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_prefs_keys.dart';
import '../../data/rental_model.dart';
import '../../service/preference_service.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(
      ),
      bottomNavigationBar: SafeArea(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(onPressed: () async {
                controller.confirmRental();
              }, child: Text("승인")),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if(controller.isInitialized.value){
          return Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Obx(() => Text("모니터석 ${controller.monitorCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.monitorCount.value == 0) return;
                          controller.monitorCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.monitorCount, controller.monitorCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.monitorCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.monitorCount, controller.monitorCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Text("모니터석 전체 ${controller.monitorTotalCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.monitorTotalCount.value == 0) return;
                          controller.monitorTotalCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.monitorTotalCount, controller.monitorTotalCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.monitorTotalCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.monitorTotalCount, controller.monitorTotalCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Text("데스크탑 ${controller.desktopCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.desktopCount.value == 0) return;
                          controller.desktopCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.desktopCount, controller.desktopCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.desktopCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.desktopCount, controller.desktopCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Text("데스크탑 전체 ${controller.desktopTotalCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.desktopTotalCount.value == 0) return;
                          controller.desktopTotalCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.desktopTotalCount, controller.desktopTotalCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.desktopTotalCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.desktopTotalCount, controller.desktopTotalCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Text("그룹학습 ${controller.groupStudyCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.groupStudyCount.value == 0) return;
                          controller.groupStudyCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.groupStudyCount, controller.groupStudyCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.groupStudyCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.groupStudyCount, controller.groupStudyCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(() => Text("그룹학습 전체 ${controller.groupStudyTotalCount.value}"),),
                        const Expanded(child: SizedBox()),
                        TextButton(onPressed: () {
                          if(controller.groupStudyTotalCount.value == 0) return;
                          controller.groupStudyTotalCount.value -= 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.groupStudyTotalCount, controller.groupStudyTotalCount.value);
                        }, child: Text("-",style: TextStyle(fontSize: 30),)),
                        TextButton(onPressed: () {
                          controller.groupStudyTotalCount.value += 1;
                          AppPreferences().prefs?.setInt(AppPrefsKeys.groupStudyTotalCount, controller.groupStudyTotalCount.value);
                        }, child: Text("+",style: TextStyle(fontSize: 30),)),
                      ],
                    ),
                    Text("대여 / 반납 요청 내역", style: TextStyle(fontSize: 20),),
                    const SizedBox(height: 20,),
                    Divider(height: 1, thickness: 1, color: AppColors.grey600,),
                    const SizedBox(height: 20,),
                    ListView.builder(
                        itemCount: controller.rentalLists.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Obx((){

                          var item = controller.rentalLists[index];

                          return GestureDetector(
                            onTap: () {
                              if(controller.selectedRequestsUids.contains(item.uid)){
                                controller.selectedRequestsUids.remove(item.uid);
                                return;
                              }
                              controller.selectedRequestsUids.add(item.uid);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${item.type == "rental" ? "대여" : "반납"}"),
                                        Text("신청인 : ${"김홍익"}"),
                                        Text("기종 : ${item.deviceCategory}"),
                                        Text("품번 : ${item.deviceName}"),
                                      ],
                                    ),
                                  ),
                                  Checkbox(
                                    value: controller.selectedRequestsUids.contains(item.uid),
                                    onChanged: (value) {

                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        ))
                  ],
                ),
              ),
            ),
          );
        }else {
          return Center(child: CircularProgressIndicator(),);
        }
      },),
    );
  }

}




class AdminController extends GetxController{

  RxInt monitorCount = 0.obs;
  RxInt desktopCount = 0.obs;
  RxInt groupStudyCount = 0.obs;
  RxInt monitorTotalCount = 0.obs;
  RxInt desktopTotalCount = 0.obs;
  RxInt groupStudyTotalCount = 0.obs;
  RxList selectedRequestsUids = <String>[].obs;
  RxList<RentalModel> rentalLists = RxList.empty();
  var isInitialized = false.obs;


  @override
  void onInit() {
    monitorCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.monitorCount) ?? 0;
    desktopCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.desktopCount) ?? 0;
    groupStudyCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.groupStudyCount) ?? 0;
    monitorTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.monitorTotalCount) ?? 0;
    desktopTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.desktopTotalCount) ?? 0;
    groupStudyTotalCount.value = AppPreferences().prefs?.getInt(AppPrefsKeys.groupStudyTotalCount) ?? 0;
    initData();
    super.onInit();
  }

  Future<void> initData() async{
    rentalLists.value = await RentalModel.getRentalInfoList();
    rentalLists.value = rentalLists.where((element) {
      return element.status == "wait";
    },).toList();
    isInitialized(true);
  }

  Future<void> confirmRental() async {
    var selectedRentalList = rentalLists
        .where((rental) => selectedRequestsUids.contains(rental.uid))
        .toList();
    for(var rental in selectedRentalList){
      await RentalModel.updateRentalByUid(rental.uid, rental.type == "rental" ? "rental_confirm" : "return_confirm");
    }
    rentalLists.value = await RentalModel.getRentalInfoList();
    rentalLists.value = rentalLists.where((element) {
      return element.status == "wait";
    },).toList();

    Fluttertoast.showToast(msg: "처리 되었습니다.");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

}
