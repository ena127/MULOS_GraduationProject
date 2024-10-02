import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          ExpansionTile(
            initiallyExpanded: true,
            collapsedBackgroundColor: AppColors.grey100,
            backgroundColor: AppColors.grey100,

            title: const Text("대여"),
            children: [
              const Divider(height: 1, thickness: 1, color: AppColors.grey200,),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRouter.rental);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("정규학기 대여", style: TextStyle(fontSize: 15),),
                )
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.grey200,),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("상시 장기대여", style: TextStyle(fontSize: 15),),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.grey200,),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text("당일 대여", style: TextStyle(fontSize: 15),),
              ),
            ],
          ),
          ExpansionTile(
            initiallyExpanded: true,
            title: const Text("반납"),
            collapsedBackgroundColor: AppColors.grey100,
            backgroundColor: AppColors.grey100,
            children: [
              const Divider(height: 1, thickness: 1, color: AppColors.grey200,),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRouter.return_screen);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text("반납하기", style: TextStyle(fontSize: 15),),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.grey200,),
            ],
          ),
        ],
      ),
    );
  }

}
