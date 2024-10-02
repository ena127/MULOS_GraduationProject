import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';

import 'constants/app_prefs_keys.dart';
import 'constants/app_router.dart';
import 'service/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPreferences().init();

  bool isLoginUser = AppPreferences().prefs?.getBool(AppPrefsKeys.isLoginUser) ?? false; // fcmToken 삽입

  runApp(MyApp(isLoginUser: isLoginUser,));
}

class MyApp extends StatelessWidget {

  final bool isLoginUser;

  const MyApp({
    required this.isLoginUser,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoginUser ? AppRouter.home : AppRouter.sign_in,
      getPages: AppRouter.routes,
      theme: ThemeData(
        fontFamily: "NotoSans",
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              foregroundColor: Colors.white,
              overlayColor: Colors.grey,
              textStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
          )
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF4285F4)),
          trackColor: WidgetStateProperty.all(AppColors.grey200),
          thumbVisibility: WidgetStateProperty.all(true),
        ),
        appBarTheme: const AppBarTheme(
          color: AppColors.background,
          iconTheme: IconThemeData(
              color: AppColors.backgroundReverse
          ),
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          titleTextStyle: TextStyle(fontFamily: "RubikMonoOne", fontSize: 25, color: Color(0xff00057E)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ElevatedButton.styleFrom(splashFactory: NoSplash.splashFactory,), // disable ripple
        ),
      ),
    );
  }
}

