import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/data/rental_model.dart';
import 'package:mulos/utils/format_util.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_router.dart';

class ConfirmRentalScreen extends StatelessWidget {
  const ConfirmRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ConfirmRentalController());

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
      body: Obx(() {
        if(!controller.isInitialized.value) return const SizedBox();

        return Scrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.groupedRentals.length,
                itemBuilder: (context, index) {

                  int requestTime = controller.groupedRentals.keys.elementAt(index);
                  List<RentalModel> rentalsForTime = controller.groupedRentals[requestTime]!;


                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("신청 일시 : ${FormatUtil.timestampToString(requestTime)}"),
                      Text("신청기기"),
                      const SizedBox(height: 10,),
                      ListView.builder(
                        itemCount: rentalsForTime.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, rentalIndex) {

                          RentalModel rental = rentalsForTime[rentalIndex];

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
                                    Text("기종 : ${rental.deviceCategory}"),
                                    Text("기기 : ${rental.deviceName}"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const Text("지도교수"),
                      const SizedBox(height: 10,),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.all(Radius.circular(15))
                        ),
                        child: Text(controller.professor),
                      ),
                      const SizedBox(height: 10,),
                      const Text("상태"),
                      const SizedBox(height: 5,),
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                          decoration: const BoxDecoration(
                              color: Color(0xffEA4335),
                              borderRadius: BorderRadius.all(Radius.circular(100))
                          ),
                          child: const Text("승인 대기", style: TextStyle(color: Colors.white),)
                      ),
                      const SizedBox(height: 30,),
                      Divider(height: 1, thickness: 1, color: AppColors.grey300,),
                      const SizedBox(height: 50,),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },),
    );
  }

}




class ConfirmRentalController extends GetxController{

  late List<RentalModel> rentalDevices;
  late Map<int, List<RentalModel>> groupedRentals;
  late String professor;
  var isInitialized = false.obs;

  @override
  void onInit() {
    professor = Get.arguments["professor"];
    initData();
    super.onInit();
  }

  Future<void> initData() async {

    if(Get.arguments["rentalDevices"] == null){
      rentalDevices = await RentalModel.getRentalInfoList();
    }else {
      rentalDevices = Get.arguments["rentalDevices"];
    }
    groupedRentals = groupByRequestTime(rentalDevices);
    isInitialized(true);
  }

  @override
  void onClose() {
    super.onClose();
  }


  Map<int, List<RentalModel>> groupByRequestTime(List<RentalModel> rentals) {
    return rentals.fold({}, (Map<int, List<RentalModel>> map, RentalModel rental) {
      map[rental.requestTime] ??= [];
      map[rental.requestTime]!.add(rental);
      return map;
    });
  }


}