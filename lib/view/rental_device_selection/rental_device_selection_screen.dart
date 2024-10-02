import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_router.dart';

import '../../constants/app_colors.dart';

class RentalDeviceSelectionScreen extends StatelessWidget {
  const RentalDeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(RentalDeviceSelectionController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS"),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Get.offNamedUntil(AppRouter.home, (route) => false);
            },
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.home_outlined),
            ),
          ),
          const SizedBox(width: 10,),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text("Windows 노트북 대여", style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
            const SizedBox(height: 20,),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {
                controller.finishSelection();
              }, child: Text("완료", style: TextStyle(color: Color(0xFF4285F4)),)),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Container(
                  color: AppColors.grey100,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity, color: const Color(0xFF4285F4),child: const Text("기종 선택")
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: RawScrollbar(
                            thickness: 5,
                            thumbColor: const Color(0xFF4285F4),
                            trackColor: AppColors.grey300,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.deviceList.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) => Obx((){

                                return Container(
                                  color: controller.selectedDevicesIndex.contains(index) ? Colors.grey.withOpacity(0.3) : Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if(controller.selectedDevicesIndex.contains(index)){
                                        controller.selectedDevicesIndex.remove(index);
                                        return;
                                      }
                                      controller.selectedDevicesIndex.add(index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text("${controller.deviceList[index]}"),
                                    )
                                  ),
                                );

                              }),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}


class RentalDeviceSelectionController extends GetxController{

  var deviceList = <String>["LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱","LG 그램", "Samsung 갤럭시북","한성 올데이롱"];
  RxList selectedDevicesIndex = <int>[].obs;

  void finishSelection () {
    if(selectedDevicesIndex.isEmpty){
      Fluttertoast.showToast(msg: "기기를 선택해주세요.");
      return;
    }
    var selectedList = selectedDevicesIndex.map((index) => deviceList[index]).toList();
    Get.toNamed(AppRouter.request_rental, arguments: {
      "selectedList" : selectedList,
      "deviceCategory" : "Windows 노트북",
    });
  }

}
