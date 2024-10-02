import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';
import 'package:mulos/data/rental_model.dart';
import 'package:mulos/view/common/loading_lottie.dart';
import 'package:uuid/uuid.dart';

class RequestRentalScreen extends StatelessWidget {
  const RequestRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(RequestRentalController());

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
      body: Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Obx(() {
                  if(controller.isRequestSuccess.value){
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset("assets/image/ic_send2.svg"),
                          const SizedBox(height: 50,),
                          GestureDetector(
                            onTap: () {
                              Get.offNamed(AppRouter.confirm_rental, arguments: {
                                "selected_devices":controller.selectedDevices,
                                "professor": controller.textController.value.text,
                                "rentalDevices": controller.rentalDevices
                              });
                            },
                            child: Column(
                              children: [
                                const Text("요청 내역 보러가기", style: TextStyle(fontSize: 25),),
                                const Divider(height: 2,thickness: 2,color: Colors.black,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("신청기기"),
                        const SizedBox(height: 10,),
                        ListView.builder(
                          itemCount: controller.selectedDevices.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
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
                                      Text("기종 : Windows 노트북"),
                                      Text("기기 : ${controller.selectedDevices[index]}"),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const Text("지도교수"),
                        const SizedBox(height: 10,),
                        TextField(
                          textInputAction: TextInputAction.done,
                          controller: controller.textController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            filled: true,
                            fillColor: AppColors.grey100,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(15),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50,),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(onPressed: () {
                            if(controller.textController.value.text.isEmpty){
                              Fluttertoast.showToast(msg: "지도교수님 성함을 적어주세요.");
                              return;
                            }
                            controller.requestRental();
                          }, child: Text("승인 요청")),
                        )
                      ],
                    );
                  }
                },),
              ),
            ),
          ),
          Obx(() {
            if(!controller.isLoading.value) return const SizedBox();
            return const Center(child: LottieLoading());
          },),
        ],
      ),
    );
  }

}

class RequestRentalController extends GetxController{

  late TextEditingController textController;
  late List<String> selectedDevices;
  late String deviceCategory;
  var isRequestSuccess = false.obs;
  var isLoading = false.obs;
  List<RentalModel> rentalDevices = [];

  @override
  void onInit() {
    textController = TextEditingController();
    selectedDevices = Get.arguments["selectedList"];
    deviceCategory = Get.arguments["deviceCategory"];
    super.onInit();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }


  Future<void> requestRental() async {

    var currentTime = DateTime.now().millisecondsSinceEpoch;

    for (var device in selectedDevices) {
      var rentalModel = RentalModel(
        uid: const Uuid().v4(),
        type: "rental",
        deviceCategory: deviceCategory,
        deviceName: device,
        professor: textController.value.text,
        requestTime: currentTime,
        approveTime: 0,
        status: "wait"
      );
      rentalDevices.add(rentalModel);
    }

    await RentalModel.saveRentalInfoList(rentalDevices);

    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 2000));
    isLoading(false);
    isRequestSuccess(true);


  }

}
