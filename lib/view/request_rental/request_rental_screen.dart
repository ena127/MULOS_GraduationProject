import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_router.dart';
import '../../service/api_service.dart';

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
                  if (controller.isRequestSuccess.value) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("기기 대여 요청이 성공적으로 완료되었습니다!"),
                          ElevatedButton(
                            onPressed: () {
                              Get.offNamed(AppRouter.confirm_rental);
                            },
                            child: const Text("요청 내역 보러가기"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("신청 기기"),
                        const SizedBox(height: 10),
                        ListView.builder(
                          itemCount: controller.selectedDevices.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              child: Text("기기: ${controller.selectedDevices[index]}"),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text("지도 교수 선택"),
                        const SizedBox(height: 10),
                        ListView.builder(
                          itemCount: controller.professors.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final professor = controller.professors[index];
                            return ListTile(
                              title: Text(professor),
                              onTap: () => controller.selectProfessor(professor),
                              selected: controller.selectedProfessor.value == professor,
                              selectedTileColor: AppColors.grey300,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.requestRental();
                            },
                            child: const Text("승인 요청"),
                          ),
                        ),
                      ],
                    );
                  }
                }),
              ),
            ),
          ),
          Obx(() {
            if (!controller.isLoading.value) return const SizedBox();
            return const Center(child: CircularProgressIndicator());
          }),
        ],
      ),
    );
  }
}

class RequestRentalController extends GetxController {
  final ApiService apiService = ApiService();

  var professors = <String>[].obs; // 교수님 리스트
  var selectedProfessor = ''.obs; // 선택된 교수님
  var selectedDevices = <String>[].obs; // 선택된 기기들
  var isLoading = false.obs;
  var isRequestSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 선택된 기기와 교수님 리스트 초기화
    selectedDevices.addAll(Get.arguments['selectedList'] ?? []);
    fetchProfessors();
  }

  void fetchProfessors() async {
    try {
      final professorList = await apiService.getProfessors(); // API를 통해 교수님 목록 가져오기
      professors.addAll(professorList); // 문자열 리스트 추가
      print("Fetched professors: $professorList"); // 디버깅용 로그
    } catch (e) {
      Fluttertoast.showToast(msg: "교수님 목록을 불러오는 데 실패했습니다.");
      print("Error fetching professors: $e"); // 디버깅용 로그
    }
  }

  void selectProfessor(String professor) {
    selectedProfessor.value = professor;
  }

  Future<void> requestRental() async {
    if (selectedProfessor.value.isEmpty) {
      Fluttertoast.showToast(msg: "교수님을 선택해주세요.");
      return;
    }

    if (selectedDevices.isEmpty) {
      Fluttertoast.showToast(msg: "선택된 기기가 없습니다.");
      return;
    }

    isLoading.value = true;

    try {
      for (var device in selectedDevices) {
        await apiService.addRental({
          'device_name': device,
          'professor': selectedProfessor.value,
        });
      }
      isRequestSuccess.value = true;
      Fluttertoast.showToast(msg: "기기가 성공적으로 선택됐습니다.");
    } catch (e) {
      Fluttertoast.showToast(msg: "대여 요청 중 오류가 발생했습니다.");
    } finally {
      isLoading.value = false;
    }
  }
}