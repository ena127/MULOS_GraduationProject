import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../constants/app_router.dart';
import '../../constants/app_colors.dart';
import '../../service/api_service.dart';
import '../../service/preference_service.dart';

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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            // 기기 모델 선택 ListView
            Expanded(
              flex: 2,
              child: Obx(() {
                if (controller.deviceModels.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: controller.deviceModels.length,
                  itemBuilder: (context, index) {
                    final model = controller.deviceModels[index];
                    return ListTile(
                      title: Text(model),
                      onTap: () => controller.selectModel(model),
                      selected: controller.selectedModel.value == model,
                      selectedTileColor: AppColors.grey300,
                    );
                  },
                );
              }),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.grey600),

            // 기기명 선택 ListView
            Expanded(
              flex: 3,
              child: Obx(() {
                if (controller.deviceNames.isEmpty) {
                  return const Center(
                    child: Text("모델명을 먼저 선택하세요"),
                  );
                }
                return ListView.builder(
                  itemCount: controller.deviceNames.length,
                  itemBuilder: (context, index) {
                    final deviceName = controller.deviceNames[index];
                    return ListTile(
                      title: Text(deviceName),
                      onTap: () => controller.selectDevice(deviceName),
                      selected: controller.selectedDeviceName.value == deviceName,
                      selectedTileColor: AppColors.grey300,
                    );
                  },
                );
              }),
            ),

            // 완료 버튼
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  controller.finishSelection();
                },
                child: const Text("완료"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RentalDeviceSelectionController extends GetxController {
  final ApiService apiService = ApiService();

  String deviceType = ''; // 선택된 타입
  var deviceModels = <String>[].obs; // 모델 목록
  var deviceNames = <String>[].obs; // 기기명 목록
  RxString selectedModel = ''.obs; // 선택된 모델
  RxString selectedDeviceName = ''.obs; // 선택된 기기명


  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration(milliseconds: 500), () async {
      await _initializePreferences();
      deviceType = Get.arguments; // RentalScreen에서 전달된 타입
      fetchDeviceModels(); // 초기 모델 목록 가져오기
    });
  }

  Future<void> _initializePreferences() async {
    final appPreferences = AppPreferences();
    await appPreferences.init(); // 강제 초기화 보장


    try {
      // SecureStorage 데이터 확인
      final studentId = await appPreferences.get('student_id');
      print('RentalDeviceSelectionController - Retrieved studentId: $studentId');

      if (studentId == null) {
        print('Error: studentId is null');
        // Optional: 추가 처리를 위해 로직 삽입
      }
    } catch (e) {
      print('Error accessing SecureStorage: $e');
    }
  }

  /// 모델 목록 가져오기
  Future<void> fetchDeviceModels() async {
    try {
      final models = await apiService.getDeviceModels(deviceType);
      deviceModels.assignAll(models);
    } catch (e) {
      Fluttertoast.showToast(msg: "모델 목록을 가져오는 데 실패했습니다.");
    }
  }

  /// 모델 선택 처리
  void selectModel(String model) {
    selectedModel.value = model;
    fetchAvailableDevices(model); // 선택된 모델에 따른 기기명 목록 가져오기
  }

  /// 기기명 목록 가져오기
  Future<void> fetchAvailableDevices(String model) async {
    try {
      final devices = await apiService.getAvailableDevices(model);
      deviceNames.assignAll(devices);
      selectedDeviceName.value = ''; // 선택 초기화
    } catch (e) {
      Fluttertoast.showToast(msg: "기기명을 가져오는 데 실패했습니다.");
    }
  }

  /// 기기명 선택 처리
  void selectDevice(String deviceName) {
    selectedDeviceName.value = deviceName;
  }

  /// 대여 요청 처리
  /// 대여 요청 처리
  Future<void> finishSelection() async {
    if (selectedDeviceName.isEmpty) {
      Fluttertoast.showToast(msg: "기기를 선택해주세요.");
      return;
    }

    final appPreferences = AppPreferences();

    // 강제 초기화
    if (appPreferences.prefs == null) {
      print("AppPreferences not initialized. Reinitializing...");
      await appPreferences.init();
    }

    final studentId = await appPreferences.get('studentId');
    print('Retrieved studentId: $studentId'); // 디버깅 로그 추가
    print('finishSelection - Selected device name: ${selectedDeviceName.value}');

    if (studentId == null) {
      Fluttertoast.showToast(msg: "로그인 정보가 없습니다. 다시 로그인해주세요.");
      Get.offNamed(AppRouter.sign_in);
      return;
    }
    // `device_name`으로 `device_id` 조회
    int? deviceId = await apiService.getDeviceIdByName(selectedDeviceName.value);

    if (deviceId == null) {
      Fluttertoast.showToast(msg: "선택한 기기의 ID를 찾을 수 없습니다.");
      return;
    }

    // API 호출 데이터 구성
    final rentalRequestData = {
      'student_id': studentId,
      'device_name': selectedDeviceName.value,
      'request_date': DateTime.now().toIso8601String(),
      'status': 'pending',
    };

    try {
      final success = await apiService.addRental(rentalRequestData);
      if (success) {
        Fluttertoast.showToast(msg: "기기 대여가 완료되었습니다.");
        Get.toNamed(
          AppRouter.request_rental,
          arguments: {
            'selectedList': [selectedDeviceName.value], // 선택된 기기 목록 전달
            'deviceCategory': deviceType, // 기기 카테고리
          },
        );
      } else {
        Fluttertoast.showToast(msg: "기기 대여에 실패했습니다.");
      }
    } catch (e) {
      print('Error in finishSelection: $e');
      Fluttertoast.showToast(msg: "대여 요청 중 오류가 발생했습니다.");
    }
  }
}