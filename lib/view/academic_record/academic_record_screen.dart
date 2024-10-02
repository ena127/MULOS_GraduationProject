import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_prefs_keys.dart';
import '../../constants/app_router.dart';
import '../../service/preference_service.dart';

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
              const Text("학적 인증", style: TextStyle(fontSize: 20),),
              const SizedBox(height: 20,),
              const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
              const SizedBox(height: 40,),
              Align(alignment: Alignment.centerLeft,child: Text("이미지 예시")),
              const SizedBox(height: 4,),
              Obx(() {
                if(controller.selectedImage.value == null){
                  return Image.asset("assets/image/sample_image.png");
                }else {
                  return Image.file(File(controller.selectedImage.value!.path));
                }
              },),
              const SizedBox(height: 10,),
              Text("클래스넷 > 개인정보 > 기본정보 이미지 캡쳐"),
              const SizedBox(height: 40,),
              Obx(() {
                return ElevatedButton(onPressed: () async {
                  if(controller.selectedImage.value == null) {
                    controller.pickImage();
                    return;
                  }
                  await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true) ?? false;
                  Get.offNamedUntil(AppRouter.home, (route) => false);
                }, child: Text("${controller.selectedImage.value == null ? "갤러리에서 탐색하기" : "가입 완료"}"));
              },)
            ],
          ),
        ),
      ),
    );
  }

}


class AcademicRecordController extends GetxController{


  var selectedImage = Rx<XFile?>(null);



  Future<void> pickImage() async {

    try{
      var selectedXfile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if(selectedXfile != null){
        selectedImage.value = selectedXfile;
      }

    }catch (e){
      Fluttertoast.showToast(msg: "Exception occured! ::: $e");
    }

  }

}
