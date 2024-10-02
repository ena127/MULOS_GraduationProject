import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/view/common/bouncing_button.dart';

class RentalItem extends StatelessWidget {

  final String title;
  final VoidCallback onTap;

  const RentalItem({
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
        margin: const EdgeInsets.symmetric(vertical: 13),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.all(Radius.circular(30))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: false,
              child: SvgPicture.asset("assets/image/ic_send.svg")
            ),
            Text(title, textAlign: TextAlign.center,),
            SvgPicture.asset("assets/image/ic_send.svg"),
          ],
        ),
      ),
    );
  }

}
