import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/service/api_service.dart';
import '../../constants/app_router.dart';

class AcademicRecordScreen extends StatelessWidget {
  const AcademicRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AcademicRecordController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text("학적 인증", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const Divider(height: 1, thickness: 1, color: AppColors.grey600),
              const SizedBox(height: 40),
              Align(alignment: Alignment.centerLeft, child: const Text("이미지 예시")),
              const SizedBox(height: 4),
              Obx(() {
                if (controller.selectedImage.value == null) {
                  return Image.asset("assets/image/sample_image.png");
                } else {
                  return Image.file(File(controller.selectedImage.value!.path));
                }
              }),
              const SizedBox(height: 10),
              const Text("클래스넷 > 개인정보 > 기본정보 이미지 캡쳐"),
              const SizedBox(height: 40),
              Obx(() {
                return ElevatedButton(
                  onPressed: () async {
                    if (controller.selectedImage.value == null) {
                      controller.pickImage();
                      return;
                    }
                    await controller.completeSignUp();
                  },
                  child: Text(controller.selectedImage.value == null
                      ? "갤러리에서 탐색하기"
                      : "가입 완료"),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}

class AcademicRecordController extends GetxController {
  final ApiService apiService = ApiService();
  var selectedImage = Rx<XFile?>(null);
  late String studentId;
  late String password;

  void setUserInfo(String id, String passwd) {
    studentId = id;
    password = passwd;
  }

  Future<void> pickImage() async {
    try {
      var selectedXfile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedXfile != null) {
        selectedImage.value = selectedXfile;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "이미지 선택 중 오류 발생: $e");
    }
  }

  Future<void> completeSignUp() async {
    if (selectedImage.value != null) {
      final photoUrl = await apiService.uploadImage(File(selectedImage.value!.path));
      if (photoUrl != null) {
        Map<String, dynamic> userData = {
          'student_id': studentId,
          'password': password,
          'photo_url': photoUrl,
          'role': 'student',
          'email': 'example@example.com',
          'name': 'Student Name',
          'professor': 'Professor Name'
        };

        print("[DEBUG] Registering user with data: $userData");


        bool isRegistered = await apiService.registerUser(userData);
        if (isRegistered) {
          Fluttertoast.showToast(msg: "회원가입이 완료되었습니다.");
          Get.offNamed(AppRouter.sign_in); //11.18 로그인 페이지로 이동되도록 수정, Allnamed-> named로 바꿔 현재만 삭제하도록
        } else {
          Fluttertoast.showToast(msg: "회원가입에 실패했습니다.");
        }
      } else {
        Fluttertoast.showToast(msg: "이미지 업로드에 실패했습니다.");
      }
    } else {
      Fluttertoast.showToast(msg: "이미지를 선택해주세요.");
    }
  }
}