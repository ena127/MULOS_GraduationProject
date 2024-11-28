import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../constants/app_prefs_keys.dart';
import '../../service/preference_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    return Scaffold(
      body: SafeArea(
        child: Center( // 부모 위젯을 Center로 설정하여 자식들을 중앙 정렬
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 수평으로 중앙 정렬
              mainAxisAlignment: MainAxisAlignment.center, // 수직으로 중앙 정렬
              children: [
                Image.asset(
                  "assets/image/app_icon.png",
                  width: shortestSide * 0.8,
                  height: shortestSide * 0.8,
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return ElevatedButton(
                    onPressed: () {
                      if (controller.qrData.value.isEmpty) {
                        controller.fetchQrFromServer();
                      }
                    },
                    child: Text(controller.qrData.value.isEmpty ? "QR 생성" : "QR 생성됨"),
                  );
                }),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.qrData.value == "static") {
                    return Image.asset(
                      'assets/image/qr_code.png', // Static QR 코드 이미지 경로
                      width: 200.0,
                      height: 200.0,
                    );
                  } else if (controller.qrData.value.isNotEmpty) {
                    return QrImageView(
                      data: controller.qrData.value,
                      version: QrVersions.auto,
                      size: 200.0,
                    );
                  } else {
                    return const Text("QR을 생성하세요.");
                  }
                }),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
                    children: [
                      const Text("좌석 현황"),
                      Obx(() {
                        return Text(
                          "현재 인원: ${controller.personCount.value}/${controller.personTotalCount.value}",
                          style: const TextStyle(fontSize: 15),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.congestionStatusColor.value,
                    ),
                    child: Text(
                      controller.congestionStatus.value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey200,
              offset: Offset(0, -5),
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SafeArea(
              top: false,
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
                        const Icon(Icons.desktop_mac_outlined, size: 40),
                        const Text("RENTAL"),
                      ],
                    ),
                  ),
                  const SizedBox(),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRouter.user);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sentiment_satisfied, size: 40),
                        const Text("MY"),
                      ],
                    ),
                  ),
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
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.main,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.home_outlined, size: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  var qrData = ''.obs;
  RxInt remainingSeconds = 30.obs;
  Timer? timer;

  // 혼잡도 관련 필드
  RxInt personCount = 0.obs;
  RxInt personTotalCount = 60.obs;
  var congestionStatus = '보통'.obs;
  var congestionStatusColor = Colors.yellow.obs;

  // 사용자 정보 관련 필드
  RxString studentId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchCongestionData();
      loadUserInfo();
    });
  }

  void loadUserInfo() {
    // AppPreferences에서 studentId 로드
    studentId.value = AppPreferences().prefs?.getString('studentId') ?? '';
    print("[DEBUG] Loaded studentId: ${studentId.value}");
  }

  Future<void> fetchCongestionData() async {
    try {
      final response = await http.get(Uri.parse('http://3.39.184.195:5000/congestion'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        personCount.value = data['person_count'] ?? 0;
        personTotalCount.value = data['person_total_count'] ?? 60;
        congestionStatus.value = data['congestion_status'] ?? '데이터 없음';
        congestionStatusColor.value = congestionStatus.value == '쾌적'
            ? Colors.green
            : congestionStatus.value == '혼잡'
            ? Colors.red
            : Colors.yellow;
      } else {
        print("Failed to fetch congestion data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception while fetching congestion data: $e");
    }
  }
  /*
  Future<void> fetchQrFromServer() async {
    try {
      final url = 'http://3.39.184.195:5000/qrcode/generate';
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({'student_id': studentId.value});

      print("[DEBUG] Sending request to: $url");
      print("[DEBUG] Request body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        qrData.value = base64Encode(response.bodyBytes);
      } else {
        print('Failed to fetch QR: ${response.body}');
      }
    } catch (e) {
      print('Error fetching QR from server: $e');
    }
  }*/
  Future<void> fetchQrFromServer() async {
    try {
      // Static QR 이미지 파일 경로를 base64로 인코딩하여 qrData에 저장
      qrData.value = "static";
      print("[DEBUG] Loaded static QR code");
    } catch (e) {
      print('Error loading static QR: $e');
    }
  }

  void stopTimer() {
    timer?.cancel();
    qrData.value = '';
  }
}