import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/view/rental/rental_item.dart';

import '../../constants/app_router.dart';

class RentalScreen extends StatelessWidget {
  const RentalScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text("정규학기 대여", style: TextStyle(fontSize: 20),),
            const SizedBox(height: 20,),
            const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
            const SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.bookmark_border, color: AppColors.grey300,size: 20,),
                      Text("공지", style: TextStyle(fontSize: 12, color: AppColors.grey600),),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text("대여 신청 기간 : 02020 ~", style: TextStyle(fontSize: 12),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text("대여 진행 기간 :", style: TextStyle(fontSize: 12),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text("반납 기한 ~ 2024.09.29", style: TextStyle(fontSize: 12),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Text("(*해당학기 졸업예정자는 06.14 까지)", style: TextStyle(fontSize: 12),),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40,),
            RentalItem(
              onTap: () {
                Get.toNamed(AppRouter.rental_device_selection);
              },
              title: "windows 노트북 대여",
            ),
            RentalItem(
              onTap: () {

              },
              title: "MAC 노트북 대여",
            ),
            RentalItem(
              onTap: () {

              },
              title: "Galaxy Tab 대여",
            ),
            RentalItem(
              onTap: () {

              },
              title: "I-pad 대여",
            ),
          ],
        ),
      ),
    );
  }

}
