import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/service/api_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_router.dart';

class RentalDeviceSelectionScreen extends StatelessWidget {
  const RentalDeviceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RentalDeviceSelectionController());

    return Scaffold(
      appBar: AppBar(
        title: Text("${controller.deviceType} 대여"),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  controller.finishSelection();
                },
                child: const Text("완료", style: TextStyle(color: Color(0xFF4285F4))),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                child: Container(
                  color: AppColors.grey100,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        color: const Color(0xFF4285F4),
                        child: const Text("기종 선택"),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Obx(() {
                            if (controller.deviceList.isEmpty) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.deviceList.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                return Container(
                                  color: controller.selectedDevicesIndex.contains(index)
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (controller.selectedDevicesIndex.contains(index)) {
                                        controller.selectedDevicesIndex.remove(index);
                                      } else {
                                        controller.selectedDevicesIndex.add(index);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text("${controller.deviceList[index]}"),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ),
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

class RentalDeviceSelectionController extends GetxController {
  final ApiService apiService = ApiService();
  // 기기 타입 (맥, 윈도우 등)
  String deviceType = '';
  var deviceList = <String>[].obs;
  RxList<int> selectedDevicesIndex = <int>[].obs;

  // 기기 명 (맥 프로, 맥 에어 등)
  var deviceNameList = <String>[].obs;
  RxString selectedDeviceName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // 전달받은 기기 타입을 가져옴
    deviceType = Get.arguments ?? '';
    fetchDeviceModels();
  }

  /// 기기 모델을 API를 통해 가져옴
  Future<void> fetchDeviceModels() async {
    try {
      final models = await apiService.getDeviceModels(deviceType);
      deviceList.assignAll(models);
    } catch (e) {
      print('Error fetching device models: $e');
      Fluttertoast.showToast(msg: '기기 모델을 가져오는 데 실패했습니다.');
    }
  }
  // 사용 가능한 기기명 목록 가져오기
  Future<void> fetchAvailableDevices(String model) async {
    try {
      final devices = await apiService.getAvailableDevices(model);
      deviceNameList.value = devices;
    } catch (e) {
      print("Error fetching available devices: $e");
      Fluttertoast.showToast(msg: "기기 목록을 불러오는데 실패했습니다.");
    }
  }
  // 기기 선택
  void selectDevice(String deviceName) {
    selectedDeviceName.value = deviceName;
  }

  /// 기기 선택 완료 처리
  void finishSelection() {
    if (selectedDevicesIndex.isEmpty) {
      Fluttertoast.showToast(msg: "기기를 선택해주세요.");
      return;
    }
    var selectedList = selectedDevicesIndex.map((index) => deviceList[index]).toList();
    Get.toNamed(AppRouter.request_rental, arguments: {
      "selectedList": selectedList,
      "deviceCategory": deviceType,
    });
  }
}