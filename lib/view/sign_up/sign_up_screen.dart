import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_router.dart';
import '../../service/api_service.dart';
import '../../constants/app_colors.dart';
import 'package:mulos/view/academic_record/academic_record_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "회원 가입",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: AppColors.grey600),
            const SizedBox(height: 20),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text, // 영문도 입력 가능하게 수정
              controller: controller.idTextController,
              decoration: InputDecoration(
                hintText: "학번",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 13),
            TextField(
              obscureText: true,
              controller: controller.passwordTextController,
              decoration: InputDecoration(
                hintText: "비밀번호",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text("회원가입 후 최초 1회는 클래스넷 인증이 필요합니다."),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                controller.signUp();
              },
              child: const Text("클래스넷 이미지 등록하고 정보 연동하기"),
            )
          ],
        ),
      ),
    );
  }
}


class SignUpController extends GetxController {
  final ApiService apiService = ApiService();
  late TextEditingController idTextController;
  late TextEditingController passwordTextController;

  @override
  void onInit() {
    idTextController = TextEditingController();
    passwordTextController = TextEditingController();
    super.onInit();
    print("TextEditingController 초기화됨");
  }

  @override
  void onClose() {
    idTextController.dispose();
    passwordTextController.dispose();
    super.onClose();
  }

  /// 회원가입 프로세스
  void signUp() async {
    print("signUp 함수 시작");
    final studentId = idTextController.value.text;
    final password = passwordTextController.value.text;

    // 입력 값 확인
    if (studentId.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "학번과 비밀번호를 모두 입력해주세요.");
      return;
    }
    print("ID와 비밀번호 읽기 성공: $studentId, $password");

    // 학적 인증 화면으로 이동
    print("AcademicRecordController 가져오기");
    final academicRecordController = Get.put(AcademicRecordController());
    academicRecordController.setUserInfo(studentId, password);

    // 학적 인증 화면으로 페이지 이동
    print("페이지 이동 시도");
    Get.to(() => const AcademicRecordScreen());
  }
}