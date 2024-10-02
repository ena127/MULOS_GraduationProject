import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mulos/view/common/bouncing_button.dart';
import 'package:mulos/view/common/loading_lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_router.dart';

class ReturnAddPhotoScreen extends StatelessWidget {
  const ReturnAddPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ReturnAddPhotoController());

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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("기기 사진 등록"),
                  const SizedBox(height: 10,),
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
                        Text("기기 : HP probook 2-in-1 (X-32)"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.1
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {

                      var title = index == 0 ? "전면" : index == 1 ? "후면" : index == 2 ? "초기화 화면" : "로그아웃 화면";

                      return BouncingButton(
                        onTap: () {
                          controller.pickImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("$title"),
                              const SizedBox(height: 5,),
                              Icon(Icons.add_circle_outline, size: 50,),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {

                    },
                    child: Row(
                      children: [
                        Text("등록 사진 예시 보기"),
                        Transform.rotate(
                          angle: pi/4,
                          child: SvgPicture.asset("assets/image/ic_send.svg")
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40,),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(onPressed: () {
                      controller.returnDevice();
                    }, child: Text("반납 요청")),
                  )
                ],
              ),
            ),
          ),
          Obx(() {
            if(!controller.isLoading.value) return const SizedBox();
            return Center(child: LottieLoading(),);
          },)
        ],
      ),
    );
  }

}


class ReturnAddPhotoController extends GetxController{


  var isLoading = false.obs;



  Future<void> returnDevice() async {
    isLoading(true);
    await Future.delayed(const Duration(milliseconds: 2000));
    isLoading(false);
    Get.offNamedUntil(AppRouter.home, (route) => false);
  }





  Future<void> pickImage() async {

    try{
      var selectedXfile = await ImagePicker().pickImage(source: ImageSource.camera);

      if(selectedXfile != null){
        // selectedImage.value = File(selectedXfile.path);
      }

    }catch (e){
      if(Platform.isIOS){
        var status = await Permission.photos.status;
        if (status.isDenied) {
          Logger().d('Access Denied');
          openAppSettings();
        } else {
          Logger().e('Exception occured! ::: $e');
        }
      }
      return null;
    }

  }


}