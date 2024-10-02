import 'package:flutter/material.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/view/common/bouncing_button.dart';

class UserScreenItem extends StatelessWidget {

  final String title;
  final VoidCallback onTap;

  const UserScreenItem({
    required this.title,
    required this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.all(Radius.circular(30))
        ),
        child: Text("$title", textAlign: TextAlign.center,),
      ),
    );
  }

}
