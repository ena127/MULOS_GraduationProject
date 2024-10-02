import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/utils/format_util.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_router.dart';
import '../../data/rental_model.dart';

class ReturnScreen extends StatelessWidget {
  const ReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ReturnController());

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text("반납하기", style: TextStyle(fontSize: 20),),
              const SizedBox(height: 20,),
              const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
              const SizedBox(height: 50,),
              const Align(alignment: Alignment.centerLeft,child: Text("대여중인 기기")),
              Obx(() {

                if(controller.rentalLists.isEmpty) return Padding(
                  padding: const EdgeInsets.only(top:100),
                  child: Text("대여중인 기기가 없습니다"),
                );

                return Column(
                  children: [
                    ListView.builder(
                      itemCount: controller.rentalLists.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => Obx((){

                        var item = controller.rentalLists[index];

                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                  color: AppColors.grey100,
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("기종 : ${item.deviceCategory}"),
                                  Text("기기 : ${item.deviceName}"),
                                  Text("대여일자 : ${FormatUtil.timestampToString(item.requestTime)}"),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    Text.rich(TextSpan(
                        children: [
                          TextSpan(text: "반납 기한 "),
                          TextSpan(text: "28", style: TextStyle(color: Colors.red)),
                          TextSpan(text: "일 뒤"),
                        ]
                    )),
                    SizedBox(height: 20,),
                    ElevatedButton(onPressed: () {
                      controller.returnDevices();
                    }, child: Text("반납하기"))
                  ],
                );
              },)
            ],
          ),
        ),
      ),
    );
  }

}



class ReturnController extends GetxController{

  RxList<RentalModel> rentalLists = RxList.empty();


  @override
  void onInit() {
    initData();
    super.onInit();
  }

  Future<void> initData() async {
    rentalLists.value = await RentalModel.getRentalInfoList();
    rentalLists.value = rentalLists.where((element) {
      return element.status == "rental_confirm";
    },).toList();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> returnDevices() async {
    // for(var rental in rentalLists){
    //   await RentalModel.updateRentalByUid(rental.uid, "return_confirm");
    // }
    // rentalLists.value = await RentalModel.getRentalInfoList();
    // rentalLists.value = rentalLists.where((element) {
    //   return element.status == "return_confirm";
    // },).toList();
    //
    // Fluttertoast.showToast(msg: "반납 되었습니다.");
    Get.toNamed(AppRouter.return_add_photo);
  }

}
